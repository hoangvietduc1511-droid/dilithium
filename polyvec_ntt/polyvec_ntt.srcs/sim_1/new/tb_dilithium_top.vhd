library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_dilithium_top is
end;

architecture Behavioral of tb_dilithium_top is

  -- Clock parameters
  constant CLK_PERIOD : time := 10 ns;

  -- Signals to connect to DUT
  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';
  signal rx    : std_logic := '1';
  signal tx    : std_logic;
  signal leds  : std_logic_vector(3 downto 0);

  ----------------------------------------------------------------------------
  -- UART helper task parameters
  ----------------------------------------------------------------------------
  constant BAUD_T : time := 8680 ns; -- ~115200 baud equivalent for sim

  ----------------------------------------------------------------------------
  -- DUT declaration
  ----------------------------------------------------------------------------
  component dilithium_top
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      rx    : in  std_logic;
      tx    : out std_logic;
      leds  : out std_logic_vector(3 downto 0)
    );
  end component;

begin
  ---------------------------------------------------------------------------
  -- Instantiate DUT
  ---------------------------------------------------------------------------
  dut : dilithium_top
    port map (
      clk   => clk,
      reset => reset,
      rx    => rx,
      tx    => tx,
      leds  => leds
    );

  ---------------------------------------------------------------------------
  -- Clock generation
  ---------------------------------------------------------------------------
  clk_process : process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end process;

  ---------------------------------------------------------------------------
  -- Reset generation
  ---------------------------------------------------------------------------
  reset_process : process
  begin
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait;
  end process;

  ---------------------------------------------------------------------------
  -- UART transmit procedure: send a byte LSB-first with start/stop bits
  ---------------------------------------------------------------------------
  procedure uart_send_byte(signal tx_sig : out std_logic; data : std_logic_vector(7 downto 0)) is
  begin
    -- Start bit
    tx_sig <= '0';
    wait for BAUD_T;
    -- Data bits LSB first
    for i in 0 to 7 loop
      tx_sig <= data(i);
      wait for BAUD_T;
    end loop;
    -- Stop bit
    tx_sig <= '1';
    wait for BAUD_T;
  end procedure;

  ---------------------------------------------------------------------------
  -- Stimulus process: emulate PC sending command via UART
  ---------------------------------------------------------------------------
  stim_proc : process
    variable payload : std_logic_vector(63 downto 0);
    variable byte_val : std_logic_vector(7 downto 0);
  begin
    wait until reset = '0';
    wait for 100 ns;

    report "=== Start UART transmission ===";

    -- Send CMD = 0x01 (shake256_core)
    uart_send_byte(rx, x"01");

    -- Send 64 bytes payload (all incremental for easy check)
    for i in 0 to 63 loop
      byte_val := std_logic_vector(to_unsigned(i, 8));
      uart_send_byte(rx, byte_val);
    end loop;

    report "=== Finished sending payload ===";

    -- Wait for DUT to process and respond
    wait for 10 ms;

    report "=== Simulation completed ===";
    wait;
  end process;

end Behavioral;
