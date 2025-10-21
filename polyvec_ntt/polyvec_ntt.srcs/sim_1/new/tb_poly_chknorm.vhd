library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.poly_pkg.all;

entity tb_poly_chknorm is
end entity;

architecture sim of tb_poly_chknorm is
  --------------------------------------------------------------------------
  -- C?u hình th?c t? (Dilithium)
  --------------------------------------------------------------------------
  constant N : integer := 8;                -- ng?n cho d? mô ph?ng
  constant CLK_PERIOD : time := 10 ns;
  constant Q_HALF : integer := (Q-1)/2;     -- kho?ng [-Q/2, Q/2]

  signal clk       : std_logic := '0';
  signal rst       : std_logic := '1';
  signal start     : std_logic := '0';
  signal done      : std_logic;
  signal violation : std_logic;
  signal B         : unsigned(COEFF_WIDTH-1 downto 0);

  signal a : poly_t(0 to N-1);
begin
  --------------------------------------------------------------------------
  -- DUT
  --------------------------------------------------------------------------
  uut: entity work.poly_chknorm
    generic map (
      N => N
    )
    port map (
      clk       => clk,
      rst       => rst,
      start     => start,
      a         => a,
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
  -- Stimulus (mô ph?ng tình hu?ng th?c t? trong Dilithium)
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
    -- TEST 1: Các h? s? chu?n hóa quanh 0 (h?p l?)
    ------------------------------------------------------------------------
    report "===== TEST 1: All coefficients within [-Q/2, Q/2] under bound =====";

    B <= to_unsigned(2000000, COEFF_WIDTH);  -- ví d? bound trong Dilithium
    for i in 0 to N-1 loop
      val := (-1000000) + i * 200000;  -- [-1e6, ..., +0.4e6]
      a(i) <= to_signed(val, COEFF_WIDTH);
    end loop;

    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';
    wait until done = '1';
    wait for CLK_PERIOD;

    if violation = '0' then
      report "? PASS: All coefficients within bound";
    else
      report "? FAIL: Violation detected unexpectedly" severity error;
    end if;

    ------------------------------------------------------------------------
    -- TEST 2: M?t h? s? v??t gi?i h?n B (th?c t? x?y ra khi có sai s? làm tràn)
    ------------------------------------------------------------------------
    report "===== TEST 2: One coefficient exceeds B =====";

    B <= to_unsigned(2000000, COEFF_WIDTH);

    for i in 0 to N-1 loop
      val := (-500000) + i * 100000;  -- kho?ng [-500k .. +200k]
      a(i) <= to_signed(val, COEFF_WIDTH);
    end loop;
    a(5) <= to_signed(3000000, COEFF_WIDTH); -- v??t gi?i h?n

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
    -- TEST 3: H? s? âm l?n (? -Q/2) ? v?n h?p l? n?u |val| < B
    ------------------------------------------------------------------------
    report "===== TEST 3: Negative near -Q/2 within bound =====";

    B <= to_unsigned(4200000, COEFF_WIDTH);
    for i in 0 to N-1 loop
      val := -Q_HALF + i*100000;  -- ~[-4190208 .. -4180208]
      a(i) <= to_signed(val, COEFF_WIDTH);
    end loop;

    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';
    wait until done = '1';
    wait for CLK_PERIOD;

    if violation = '0' then
      report "? PASS: Large negative coefficients still within bound";
    else
      report "? FAIL: Detected violation incorrectly" severity error;
    end if;

    ------------------------------------------------------------------------
    -- TEST 4: C?c tr? (|val| = Q_HALF) ? v??t gi?i h?n B nh?
    ------------------------------------------------------------------------
    report "===== TEST 4: Extreme values exceeding small bound =====";

    B <= to_unsigned(1000000, COEFF_WIDTH);  -- B nh? h?n biên
    for i in 0 to N-1 loop
      val := Q_HALF - 1000*i; -- g?n biên
      a(i) <= to_signed(val, COEFF_WIDTH);
    end loop;

    start <= '1';
    wait for CLK_PERIOD;
    start <= '0';
    wait until done = '1';
    wait for CLK_PERIOD;

    if violation = '1' then
      report "? PASS: Extreme coefficients correctly flagged";
    else
      report "? FAIL: Should have detected violation" severity error;
    end if;

    ------------------------------------------------------------------------
    report "Simulation finished.";
    wait;
  end process;
end architecture;
