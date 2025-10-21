-- shake256_wrapper.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shake256_wrapper is
    port(
        clk    : in  std_logic;
        rst    : in  std_logic;
        start  : in  std_logic;
        mu     : in  std_logic_vector(511 downto 0);  -- 64 bytes (512 bits)
        c_out  : out std_logic_vector(255 downto 0);  -- 32 bytes (256 bits)
        done   : out std_logic
    );
end entity;

architecture rtl of shake256_wrapper is

    -- signals to connect to shake256_core
    signal absorb_start  : std_logic := '0';
    signal absorb_done   : std_logic := '0';
    signal squeeze_start : std_logic := '0';
    signal squeeze_done  : std_logic := '0';
    signal out_data      : std_logic_vector(8*1024-1 downto 0);

    -- internal msg buffer (1024 bytes = 8192 bits)
    signal msg_full      : std_logic_vector(8*1024-1 downto 0) := (others => '0');

    -- internal outputs/drivers (use these inside processes)
    signal done_int      : std_logic := '0';
    signal c_out_int     : std_logic_vector(255 downto 0) := (others => '0');

begin

    -- map internal signals to entity ports (concurrent assignments)
    done  <= done_int;
    c_out <= c_out_int;

    -- put mu into the low 64 bytes of msg_full (bits 511 downto 0)
    msg_full(511 downto 0) <= mu;

    -- Instantiate the provided shake256_core (must be in work library)
    U_SHAKE: entity work.shake256_core
        port map(
            clk           => clk,
            rst           => rst,
            msg           => msg_full,
            msg_len       => 64,     -- bytes
            absorb_start  => absorb_start,
            absorb_done   => absorb_done,
            squeeze_start => squeeze_start,
            outlen        => 32,     -- bytes
            out_data      => out_data,
            squeeze_done  => squeeze_done
        );

    ----------------------------------------------------------------------------
    -- FSM: control pulses to shake256_core and produce done/c_out via internal
    -- signals (done_int, c_out_int). Avoid driving port 'done' inside process.
    ----------------------------------------------------------------------------
    process(clk)
        type fsm_t is (IDLE, START_ABSORB, WAIT_ABSORB, START_SQUEEZE, WAIT_SQUEEZE, DONE_ST);
        variable state : fsm_t := IDLE;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- synchronous reset
                absorb_start  <= '0';
                squeeze_start <= '0';
                done_int      <= '0';
                c_out_int     <= (others => '0');
                state := IDLE;
            else
                -- defaults each clock (ensures pulses are one cycle)
                absorb_start  <= '0';
                squeeze_start <= '0';
                done_int      <= '0';

                case state is
                    when IDLE =>
                        if start = '1' then
                            -- issue one-cycle absorb_start pulse
                            absorb_start <= '1';
                            state := START_ABSORB;
                        end if;

                    when START_ABSORB =>
                        -- absorb_start was pulsed; wait for absorb_done
                        state := WAIT_ABSORB;

                    when WAIT_ABSORB =>
                        if absorb_done = '1' then
                            -- when absorb done, start squeeze (one-cycle pulse)
                            squeeze_start <= '1';
                            state := START_SQUEEZE;
                        end if;

                    when START_SQUEEZE =>
                        state := WAIT_SQUEEZE;

                    when WAIT_SQUEEZE =>
                        if squeeze_done = '1' then
                            -- copy first 32 bytes (256 bits) of out_data to internal output
                            -- out_data is big vector (8*1024 bytes => bits). take bits 255 downto 0
                            c_out_int <= out_data(255 downto 0);
                            done_int  <= '1';   -- signal completion for 1 cycle
                            state := DONE_ST;
                        end if;

                    when DONE_ST =>
                        -- wait for host to release start to return to IDLE
                        if start = '0' then
                            state := IDLE;
                            done_int <= '0';
                        end if;

                    when others =>
                        state := IDLE;
                end case;
            end if;
        end if;
    end process;

end architecture;
