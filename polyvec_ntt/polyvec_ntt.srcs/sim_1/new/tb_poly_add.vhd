-- ===================================================================
-- File: tb_poly_add.vhd
-- Description: Testbench for poly_add.vhd
-- ===================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_poly_add is
end entity;

architecture sim of tb_poly_add is
  constant N : natural := 8;  -- test nh? cho d? quan sát

  signal a_in  : poly_t(0 to N-1);
  signal b_in  : poly_t(0 to N-1);
  signal c_out : poly_t(0 to N-1);

begin
  ----------------------------------------------------------------------
  -- DUT: poly_add
  ----------------------------------------------------------------------
  uut: entity work.poly_add
    generic map (N => N)
    port map (
      a_in  => a_in,
      b_in  => b_in,
      c_out => c_out
    );

  ----------------------------------------------------------------------
  -- TEST PROCESS
  ----------------------------------------------------------------------
  process
  begin
    ------------------------------------------------------------------
    -- Test 1: small positive numbers
    ------------------------------------------------------------------
    report "===== TEST 1: small positive =====";
    for i in 0 to N-1 loop
      a_in(i) <= to_signed(i, COEFF_WIDTH);
      b_in(i) <= to_signed(i*2, COEFF_WIDTH);
    end loop;
    wait for 10 ns;

    for i in 0 to N-1 loop
      report "c_out(" & integer'image(i) & ") = " &
             integer'image(to_integer(c_out(i)));
    end loop;

    ------------------------------------------------------------------
    -- Test 2: negative + positive
    ------------------------------------------------------------------
    report "===== TEST 2: negative + positive =====";
    a_in(0) <= to_signed(-10, COEFF_WIDTH);
    a_in(1) <= to_signed(-5, COEFF_WIDTH);
    a_in(2) <= to_signed(0, COEFF_WIDTH);
    a_in(3) <= to_signed(5, COEFF_WIDTH);
    a_in(4) <= to_signed(10, COEFF_WIDTH);
    a_in(5) <= to_signed(15, COEFF_WIDTH);
    a_in(6) <= to_signed(20, COEFF_WIDTH);
    a_in(7) <= to_signed(25, COEFF_WIDTH);

    b_in(0) <= to_signed(1, COEFF_WIDTH);
    b_in(1) <= to_signed(2, COEFF_WIDTH);
    b_in(2) <= to_signed(3, COEFF_WIDTH);
    b_in(3) <= to_signed(4, COEFF_WIDTH);
    b_in(4) <= to_signed(5, COEFF_WIDTH);
    b_in(5) <= to_signed(6, COEFF_WIDTH);
    b_in(6) <= to_signed(7, COEFF_WIDTH);
    b_in(7) <= to_signed(8, COEFF_WIDTH);

    wait for 10 ns;

    for i in 0 to N-1 loop
      report "c_out(" & integer'image(i) & ") = " &
             integer'image(to_integer(c_out(i)));
    end loop;

    ------------------------------------------------------------------
    -- Test 3: near modulus Q (to observe overflow effect)
    ------------------------------------------------------------------
    report "===== TEST 3: near Q =====";
    for i in 0 to N-1 loop
      a_in(i) <= to_signed(Q - 2, COEFF_WIDTH);
      b_in(i) <= to_signed(5, COEFF_WIDTH);
    end loop;

    wait for 10 ns;

    for i in 0 to N-1 loop
      report "c_out(" & integer'image(i) & ") = " &
             integer'image(to_integer(c_out(i)));
    end loop;

    ------------------------------------------------------------------
    report "Simulation finished.";
    wait;
  end process;
end architecture sim;
