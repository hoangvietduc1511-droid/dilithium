library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dilithium_sign_top is
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        uart_rx     : in  std_logic;
        uart_tx     : out std_logic
    );
end dilithium_sign_top;

architecture Behavioral of dilithium_sign_top is

    --------------------------------------------------------------------
    -- UART signals
    --------------------------------------------------------------------
    signal rx_data      : std_logic_vector(7 downto 0);
    signal tx_data      : std_logic_vector(7 downto 0);
    signal rx_valid     : std_logic;
    signal tx_start     : std_logic;
    signal tx_busy      : std_logic;
    signal cmd_code     : std_logic_vector(7 downto 0);

    --------------------------------------------------------------------
    -- Control & handshake
    --------------------------------------------------------------------
    signal start_core   : std_logic;
    signal done_core    : std_logic;

    --------------------------------------------------------------------
    -- Shared data bus (512-bit)
    --------------------------------------------------------------------
    signal data_in      : std_logic_vector(511 downto 0);
    signal data_out     : std_logic_vector(511 downto 0);

begin

    --------------------------------------------------------------------
    -- UART receiver
    --------------------------------------------------------------------
    uart_rx_inst : entity work.uart_rx
        generic map (
            CLOCK_FREQ => 100_000_000,
            BAUD_RATE  => 115200
        )
        port map (
            clk        => clk,
            rst        => rst,
            rx         => uart_rx,
            rx_data    => rx_data,
            rx_valid   => rx_valid
        );

    --------------------------------------------------------------------
    -- UART transmitter
    --------------------------------------------------------------------
    uart_tx_inst : entity work.uart_tx
        generic map (
            CLOCK_FREQ => 100_000_000,
            BAUD_RATE  => 115200
        )
        port map (
            clk        => clk,
            rst        => rst,
            tx_start   => tx_start,
            tx_data    => tx_data,
            tx_busy    => tx_busy,
            tx         => uart_tx
        );

    --------------------------------------------------------------------
    -- UART command controller
    --------------------------------------------------------------------
    controller_inst : entity work.uart_command_controller
        port map (
            clk         => clk,
            rst         => rst,
            rx_valid    => rx_valid,
            rx_data     => rx_data,
            tx_busy     => tx_busy,
            tx_start    => tx_start,
            tx_data     => tx_data,
            cmd_code    => cmd_code,
            start_core  => start_core,
            done_core   => done_core,
            data_in     => data_in,
            data_out    => data_out
        );

    --------------------------------------------------------------------
    -- 16 kh?i x? lý ph?n c?ng
    --------------------------------------------------------------------

    -- 01. SHAKE256 core
    shake256_inst : entity work.shake256_core
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"01" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 02. Expand_matA
    expand_matA_inst : entity work.expand_matA
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"02" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 03. polyvecl_ntt
    polyvecl_ntt_inst : entity work.polyvecl_ntt
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"03" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 04. polyveck_ntt
    polyveck_ntt_inst : entity work.polyveck_ntt
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"04" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 05. poly_uniform_gamma1m1
    poly_uniform_gamma1m1_inst : entity work.poly_uniform_gamma1m1
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"05" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 06. polyveck_freeze
    polyveck_freeze_inst : entity work.polyveck_freeze
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"06" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 07. polyvecl_freeze
    polyvecl_freeze_inst : entity work.polyvecl_freeze
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"07" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 08. polyveck_decompose
    polyveck_decompose_inst : entity work.polyveck_decompose
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"08" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 09. poly_ntt
    poly_ntt_inst : entity work.poly_ntt
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"09" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 10. polyvecl_add
    polyvecl_add_inst : entity work.polyvecl_add
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"0A" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 11. polyveck_add
    polyveck_add_inst : entity work.polyveck_add
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"0B" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 12. polyvecl_chknorm
    polyvecl_chknorm_inst : entity work.polyvecl_chknorm
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"0C" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 13. polyveck_chknorm
    polyveck_chknorm_inst : entity work.polyveck_chknorm
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"0D" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 14. polyveck_sub
    polyveck_sub_inst : entity work.polyveck_sub
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"0E" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 15. polyveck_neg
    polyveck_neg_inst : entity work.polyveck_neg
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"0F" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

    -- 16. polyveck_make_hint
    polyveck_make_hint_inst : entity work.polyveck_make_hint
        port map (
            clk   => clk,
            rst   => rst,
            start => start_core when cmd_code = x"10" else '0',
            din   => data_in,
            dout  => data_out,
            done  => done_core
        );

end Behavioral;
