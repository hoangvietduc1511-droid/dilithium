library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity polyveck_make_hint is
    generic (
        K : natural := 4;    -- s? ?a th?c trong vector
        N : natural := 256   -- s? h? s? trong m?i ?a th?c
    );
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;

        u_vec : in  unsigned(32*K*N - 1 downto 0);
        v_vec : in  unsigned(32*K*N - 1 downto 0);

        done  : out std_logic;
        h_vec : out std_logic_vector(K*N - 1 downto 0);
        s_out : out unsigned(15 downto 0)  -- t?ng s? bit 1
    );
end entity;

architecture Behavioral of polyveck_make_hint is

    -- FSM states
    type state_t is (IDLE, DRIVE_INPUT, SAMPLE, DONE_S);
    signal state : state_t := IDLE;

    -- flat index from 0 to K*N-1
    constant TOTAL : integer := K * N;
    signal idx_flat : integer range 0 to TOTAL := 0;

    -- registers / signals
    signal a_in      : unsigned(31 downto 0) := (others => '0');
    signal b_in      : unsigned(31 downto 0) := (others => '0');
    signal hint_bit  : std_logic;
    signal hint_bit_r: std_logic;  -- sampled after 1 cycle

    signal h_reg : std_logic_vector(K*N - 1 downto 0) := (others => '0');
    signal s_reg : unsigned(15 downto 0) := (others => '0');

    signal done_reg : std_logic := '0';

begin

    -- assign output ports from internal regs
    done  <= done_reg;
    h_vec <= h_reg;
    s_out <= s_reg;

    -- instance of make_hint (assumed synchronous)
    make_hint_inst: entity work.make_hint
        port map(
            clk   => clk,
            rst   => rst,
            a_in  => a_in,
            b_in  => b_in,
            hint  => hint_bit
        );

    -- Main FSM: present inputs, wait one cycle, sample hint, store, increment index
    proc_main : process(clk)
        variable v_idx : integer;
        variable msb : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state      <= IDLE;
                idx_flat   <= 0;
                a_in       <= (others => '0');
                b_in       <= (others => '0');
                hint_bit_r <= '0';
                h_reg      <= (others => '0');
                s_reg      <= (others => '0');
                done_reg   <= '0';
            else
                case state is

                    when IDLE =>
                        done_reg <= '0';
                        if start = '1' then
                            idx_flat <= 0;
                            s_reg <= (others => '0');
                            h_reg <= (others => '0');
                            state <= DRIVE_INPUT;
                        end if;

                    when DRIVE_INPUT =>
                        -- drive a_in, b_in for current index; make_hint will process this synchronously
                        v_idx := idx_flat;
                        a_in <= u_vec(32*(v_idx+1)-1 downto 32*v_idx);
                        b_in <= v_vec(32*(v_idx+1)-1 downto 32*v_idx);
                        -- after driving inputs, wait one cycle to allow make_hint to produce hint_bit
                        state <= SAMPLE;

                    when SAMPLE =>
                        -- sample hint_bit produced by make_hint (assumes hint valid same cycle or next; adjust if decompose has more latency)
                        hint_bit_r <= hint_bit;
                        -- store into h_reg at flat index
                        h_reg(idx_flat) <= hint_bit;
                        if hint_bit = '1' then
                            s_reg <= s_reg + 1;
                        end if;

                        -- increment index or finish
                        if idx_flat = TOTAL - 1 then
                            state <= DONE_S;
                        else
                            idx_flat <= idx_flat + 1;
                            state <= DRIVE_INPUT;
                        end if;

                    when DONE_S =>
                        done_reg <= '1';
                        state <= IDLE;  -- return to IDLE (or keep in DONE_S if you prefer)
                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end architecture Behavioral;
