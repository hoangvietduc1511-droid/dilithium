library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.poly_pkg.all;

entity tb_polyveck_chknorm is
end entity;

architecture sim of tb_polyveck_chknorm is
  --------------------------------------------------------------------------
  -- C?u hình test
  --------------------------------------------------------------------------
  constant K : integer := 4;           -- s? poly trong vector
  constant N : integer := 8;           -- s? coefficient m?i poly (gi?m ?? test)
  constant CLK_PERIOD : time := 10 ns;
  constant Q_HALF : integer := (Q-1)/2;

  signal clk       : std_logic := '0';
  signal rst       : std_logic := '1';
  signal start     : std_logic := '0';
  signal done      : std_logic;
  signal violation : std_logic;
  signal B         : unsigned(COEFF_WIDTH-1 downto 0);

  signal v : polyvec_t(0 to K-1, 0 to N-1);
begin
  --------------------------------------------------------------------------
  -- DUT
  --------------------------------------------------------------------------
  uut: entity work.polyveck_chknorm
    generic map (
      K => K,
      N => N
    )
    port map (
      clk       => clk,
      rst       => rst,
      start     => start,
      v         => v,
      B         => B,
      done      => done,
      violation => violation
    );

  --------------------------------------------------------------------------
  -- Clock
  --------------------------------------------------------------------------
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for CLK_PERIOD/2;
      clk <= '1';
      wait for CLK_PERIOD/2;
    end loop;
  end process;

  --------------------------------------------------------------------------
  -- Stimulus
  --------------------------------------------------------------------------
  stim_proc : process
    variable val : integer;
  begin
    ------------------------------------------------------------------------
    -- Reset
    ------------------------------------------------------------------------
    rst <= '1';
    wait for 3*CLK_PERIOD;
    rst <= '0';
    wait for CLK_PERIOD;

    ------------------------------------------------------------------------
    -- TEST 1: All poly within bound
    ------------------------------------------------------------------------
    report "===== TEST 1: All poly within bound =====";
    B <= to_unsigned(2000000, COEFF_WIDTH);

    for i in 0 to K-1 loop
      for j in 0 to N-1 loop
        val := -1000000 + j*200000;
        v(i,j) <= to_signed(val, COEFF_WIDTH);
      end loop;
    end loop;

    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';
    wait until done = '1';
    wait for CLK_PERIOD;

    if violation = '0' then
      report "? PASS: All poly within bound";
    else
      report "? FAIL: Unexpected violation" severity error;
    end if;

    ------------------------------------------------------------------------
    -- TEST 2: One poly exceeds B
    ------------------------------------------------------------------------
    report "===== TEST 2: One poly exceeds bound =====";
    B <= to_unsigned(2000000, COEFF_WIDTH);

    for i in 0 to K-1 loop
      for j in 0 to N-1 loop
        val := -500000 + j*100000;
        v(i,j) <= to_signed(val, COEFF_WIDTH);
      end loop;
    end loop;

    -- poly th? 3 vi ph?m
    v(2,5) <= to_signed(3000000, COEFF_WIDTH);

    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';
    wait until done = '1';
    wait for CLK_PERIOD;

    if violation = '1' then
      report "? PASS: Violation correctly detected";
    else
      report "? FAIL: Expected violation not detected" severity error;
    end if;

    ------------------------------------------------------------------------
    -- TEST 3: Large negative coefficients within bound
    ------------------------------------------------------------------------
    report "===== TEST 3: Large negative coefficients within bound =====";
    B <= to_unsigned(4200000, COEFF_WIDTH);

    for i in 0 to K-1 loop
      for j in 0 to N-1 loop
        val := -Q_HALF + j*100000;  -- [-Q/2 ...]
        v(i,j) <= to_signed(val, COEFF_WIDTH);
      end loop;
    end loop;

    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';
    wait until done = '1';
    wait for CLK_PERIOD;

    if violation = '0' then
      report "? PASS: Large negative coefficients OK";
    else
      report "? FAIL: Unexpected violation" severity error;
    end if;

    ------------------------------------------------------------------------
    -- K?t thúc mô ph?ng
    ------------------------------------------------------------------------
    report "Simulation finished.";
    wait;
  end process;
end architecture;
