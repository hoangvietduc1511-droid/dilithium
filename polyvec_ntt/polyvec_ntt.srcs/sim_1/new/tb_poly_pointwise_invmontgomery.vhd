library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_poly_pointwise_invmontgomery is
end entity;

architecture sim of tb_poly_pointwise_invmontgomery is
  constant N : natural := 4; -- test nh? thôi
  constant CLK_PERIOD : time := 10 ns;

  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';
  signal start : std_logic := '0';
  signal a_in  : poly_t(0 to N-1);
  signal b_in  : poly_t(0 to N-1);
  signal c_out : poly_t(0 to N-1);
  signal done  : std_logic;

begin
  --------------------------------------------------------------------
  -- Clock
  --------------------------------------------------------------------
  clk <= not clk after CLK_PERIOD/2;

  --------------------------------------------------------------------
  -- DUT
  --------------------------------------------------------------------
  uut: entity work.poly_pointwise_invmontgomery
    generic map(N => N)
    port map(
      clk   => clk,
      reset => reset,
      start => start,
      a_in  => a_in,
      b_in  => b_in,
      c_out => c_out,
      done  => done
    );

  --------------------------------------------------------------------
  -- Stimulus
  --------------------------------------------------------------------
  stim_proc: process
  begin
    -- Gi? reset
    reset <= '1';
    wait for 20 ns;
    reset <= '0';
    wait for 20 ns;

    -- N?p d? li?u vào a_in, b_in
    a_in(0) <= to_signed(1, COEFF_WIDTH);
    a_in(1) <= to_signed(2, COEFF_WIDTH);
    a_in(2) <= to_signed(3, COEFF_WIDTH);
    a_in(3) <= to_signed(4, COEFF_WIDTH);

    b_in(0) <= to_signed(5, COEFF_WIDTH);
    b_in(1) <= to_signed(6, COEFF_WIDTH);
    b_in(2) <= to_signed(7, COEFF_WIDTH);
    b_in(3) <= to_signed(8, COEFF_WIDTH);

    -- Phát xung start
    wait until rising_edge(clk);
    start <= '1';
    wait until rising_edge(clk);
    start <= '0';

    -- Ch? ??n khi done
    wait until done = '1';
    report "Computation finished. Results available in c_out.";

    wait for 50 ns;
    wait;
  end process;
end architecture;
