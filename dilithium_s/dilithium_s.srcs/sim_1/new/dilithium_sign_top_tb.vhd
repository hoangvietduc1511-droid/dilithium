library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_dilithium_sign_top is
end entity;

architecture sim of tb_dilithium_sign_top is

  --------------------------------------------------------------------
  -- Simulation constants
  --------------------------------------------------------------------
  constant CLK_PERIOD : time := 10 ns;   -- 100 MHz
  constant BAUD_RATE  : integer := 115200;
  constant BIT_PERIOD : time := 1 sec / BAUD_RATE;

  --------------------------------------------------------------------
  -- DUT port signals
  --------------------------------------------------------------------
  signal clk   : std_logic := '0';
  signal rst   : std_logic := '1';
  signal rx    : std_logic := '1';  -- UART idle high
  signal tx    : std_logic := '1';

  --------------------------------------------------------------------
  -- IMPORTANT: declare procedures/functions in this declarative region
  -- (before the architecture 'begin') when they take signal parameters.
  --------------------------------------------------------------------
  procedure uart_send_byte(
    signal uart_rx : out std_logic;
    data           : in  std_logic_vector(7 downto 0);
    bit_time       : in  time := BIT_PERIOD
  ) is
  begin
    -- start bit
    uart_rx <= '0';
    wait for bit_time;

    -- data bits (LSB first)
    for i in 0 to 7 loop
      uart_rx <= data(i);
      wait for bit_time;
    end loop;

    -- stop bit
    uart_rx <= '1';
    wait for bit_time;
  end procedure uart_send_byte;

  --------------------------------------------------------------------
  -- Optional: helper to send ascii string
  --------------------------------------------------------------------
  procedure uart_send_string(
    signal uart_rx : out std_logic;
    s              : in string
  ) is
  begin
    for idx in s'range loop
      -- convert character to ASCII code
      uart_send_byte(uart_rx, std_logic_vector(to_unsigned(character'pos(s(idx)), 8)));
    end loop;
  end procedure uart_send_string;

begin

  --------------------------------------------------------------------
  -- Instantiate DUT (adjust entity name / ports if needed)
  --------------------------------------------------------------------
  DUT : entity work.dilithium_sign_top
    port map (
      clk   => clk,
      reset => rst,
      rx    => rx,
      tx    => tx
    );

  --------------------------------------------------------------------
  -- Clock generator
  --------------------------------------------------------------------
  clk_proc : process
  begin
    while true loop
      clk <= '0';
      wait for CLK_PERIOD/2;
      clk <= '1';
      wait for CLK_PERIOD/2;
    end loop;
  end process clk_proc;

  --------------------------------------------------------------------
  -- Reset sequence
  --------------------------------------------------------------------
  rst_proc : process
  begin
    rst <= '1';
    wait for 200 ns;
    rst <= '0';
    wait;
  end process rst_proc;

  --------------------------------------------------------------------
  -- Stimulus: send a few UART commands to DUT
  --------------------------------------------------------------------
  stim_proc : process
  begin
    wait until rst = '0';
    wait for 200 ns;

    report "TB: send 'S' (0x53) to start - example" severity note;
    uart_send_byte(rx, x"53");   -- ASCII 'S' to start
    wait for 5 ms;

    report "TB: send 'E' (0x45) Expand_matA" severity note;
    uart_send_byte(rx, x"45");
    wait for 5 ms;

    report "TB: send 'V' (0x56) polyvecl_ntt" severity note;
    uart_send_byte(rx, x"56");
    wait for 5 ms;

    report "TB: send 'K' (0x4B) polyveck_ntt" severity note;
    uart_send_byte(rx, x"4B");
    wait for 5 ms;

    report "TB: finished stimuli" severity note;
    wait;
  end process stim_proc;

  --------------------------------------------------------------------
  -- Optional monitor: detect TX transitions (simple)
  --------------------------------------------------------------------
  watchdog_proc : process
  begin
    wait on tx;
    report "TB: tx changed to " & std_logic'image(tx) severity note;
  end process watchdog_proc;

end architecture sim;
