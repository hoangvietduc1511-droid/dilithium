library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity poly_uniform_gamma1m1 is
    generic (
        N_COEFF : integer := 256;
        COEFF_W : integer := 32;
        GAMMA1  : integer := 8380417
    );
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        start  : in  std_logic;
        key    : in  std_logic_vector(639 downto 0);  -- 80 bytes
        nonce  : in  std_logic_vector(15 downto 0);   -- 2 bytes
        done   : out std_logic;
        coeffs : out std_logic_vector(N_COEFF*COEFF_W-1 downto 0)
    );
end entity;

architecture rtl of poly_uniform_gamma1m1 is

    ----------------------------------------------------------------
    -- SHAKE / REJ constants
    ----------------------------------------------------------------
    constant SHAKE_RATE     : natural := 136;         -- bytes per block
    constant SHAKE5_LEN     : natural := 5*SHAKE_RATE;-- 5 blocks
    constant SHAKE1_LEN     : natural := SHAKE_RATE;  -- 1 block

    ----------------------------------------------------------------
    -- FSM / control signals
    ----------------------------------------------------------------
    type state_t is (
        IDLE,
        ABSORB_START,
        WAIT_ABSORB,
        SQUEEZE_START_5,
        WAIT_SQUEEZE_5,
        REJ_5,
        CHECK_CTR,
        SQUEEZE_START_1,
        WAIT_SQUEEZE_1,
        REJ_1,
        FINISH
    );
    signal state : state_t := IDLE;

    -- Internal control signals (tách bi?t v?i port map)
    signal shake_absorb_start  : std_logic := '0';
    signal shake_squeeze_start : std_logic := '0';
    signal rej_start_s         : std_logic := '0';

    -- SHAKE256 signals
    signal shake_msg     : std_logic_vector(8*1024-1 downto 0) := (others => '0');
    signal shake_msg_len : natural := 82;  -- key(80) + nonce(2)
    signal absorb_done   : std_logic := '0';
    signal squeeze_done  : std_logic := '0';
    signal shake_out     : std_logic_vector(8*1024-1 downto 0);
    signal shake_outlen  : natural := SHAKE5_LEN;

    -- REJ / coeffs
    signal rej_done      : std_logic := '0';
    signal coeffs_s      : std_logic_vector(N_COEFF*COEFF_W-1 downto 0);

    -- counter ?? check ctr < N_COEFF
    signal ctr           : integer range 0 to N_COEFF := 0;

begin
    coeffs <= coeffs_s;
    done   <= '1' when state = FINISH else '0';

    ----------------------------------------------------------------
    -- SHAKE256 core instance
    ----------------------------------------------------------------
    SHAKE_INST : entity work.shake256_core
        port map(
            clk           => clk,
            rst           => rst,
            msg           => shake_msg,
            msg_len       => shake_msg_len,
            absorb_start  => shake_absorb_start,
            absorb_done   => absorb_done,
            squeeze_start => shake_squeeze_start,
            outlen        => shake_outlen,
            out_data      => shake_out,
            squeeze_done  => squeeze_done
        );

    ----------------------------------------------------------------
    -- REJ instance for 5 blocks
    ----------------------------------------------------------------
    REJ_INST_5 : entity work.rej_gamma1m1
        generic map(
            LEN    => N_COEFF,
            GAMMA1 => GAMMA1,
            BUFLEN => SHAKE5_LEN
        )
        port map(
            clk    => clk,
            rst    => rst,
            start  => rej_start_s,
            key    => key,
            nonce  => nonce,
            buf_in => shake_out(SHAKE5_LEN*8-1 downto 0),
            done   => rej_done,
            a_flat => coeffs_s
        );

    ----------------------------------------------------------------
    -- REJ instance for 1 block (block th? 6)
    ----------------------------------------------------------------
    REJ_INST_1 : entity work.rej_gamma1m1
        generic map(
            LEN    => N_COEFF,
            GAMMA1 => GAMMA1,
            BUFLEN => SHAKE1_LEN
        )
        port map(
            clk    => clk,
            rst    => rst,
            start  => rej_start_s,
            key    => key,
            nonce  => nonce,
            buf_in => shake_out(SHAKE1_LEN*8-1 downto 0),
            done   => rej_done,
            a_flat => coeffs_s
        );

    ----------------------------------------------------------------
    -- FSM process (all internal signals driven here)
    ----------------------------------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            state                 <= IDLE;
            shake_absorb_start    <= '0';
            shake_squeeze_start   <= '0';
            rej_start_s           <= '0';
            shake_msg             <= (others => '0');
            ctr                   <= 0;
            shake_outlen          <= SHAKE5_LEN;
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    shake_absorb_start  <= '0';
                    shake_squeeze_start <= '0';
                    rej_start_s         <= '0';
                    ctr <= 0;
                    if start = '1' then
                        -- pack key||nonce
                        shake_msg(639 downto 0)   <= key;
                        shake_msg(655 downto 640) <= nonce;
                        shake_absorb_start         <= '1';
                        state <= ABSORB_START;
                    end if;

                when ABSORB_START =>
                    shake_absorb_start <= '0';
                    state <= WAIT_ABSORB;

                when WAIT_ABSORB =>
                    if absorb_done = '1' then
                        shake_squeeze_start <= '1';
                        shake_outlen <= SHAKE5_LEN; -- 5 blocks
                        state <= SQUEEZE_START_5;
                    end if;

                when SQUEEZE_START_5 =>
                    shake_squeeze_start <= '0';
                    state <= WAIT_SQUEEZE_5;

                when WAIT_SQUEEZE_5 =>
                    if squeeze_done = '1' then
                        rej_start_s <= '1';
                        state <= REJ_5;
                    end if;

                when REJ_5 =>
                    rej_start_s <= '0';
                    if rej_done = '1' then
                        ctr <= N_COEFF; -- gi? l?p ??
                        state <= CHECK_CTR;
                    end if;

                when CHECK_CTR =>
                    if ctr < N_COEFF then
                        shake_squeeze_start <= '1';
                        shake_outlen <= SHAKE1_LEN; -- block th? 6
                        state <= SQUEEZE_START_1;
                    else
                        state <= FINISH;
                    end if;

                when SQUEEZE_START_1 =>
                    shake_squeeze_start <= '0';
                    state <= WAIT_SQUEEZE_1;

                when WAIT_SQUEEZE_1 =>
                    if squeeze_done = '1' then
                        rej_start_s <= '1';
                        state <= REJ_1;
                    end if;

                when REJ_1 =>
                    rej_start_s <= '0';
                    if rej_done = '1' then
                        state <= FINISH;
                    end if;

                when FINISH =>
                    if start = '0' then
                        state <= IDLE;
                    end if;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end architecture;
