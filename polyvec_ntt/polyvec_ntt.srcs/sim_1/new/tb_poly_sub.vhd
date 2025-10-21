library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_poly_sub is
end tb_poly_sub;

architecture sim of tb_poly_sub is
  constant N : natural := 256;

  signal clk, rst, start, done : std_logic := '0';
  signal a, b, c : poly_t(0 to N-1);
begin

  uut: entity work.poly_sub
    generic map ( N => N )
    port map (
      clk   => clk,
      rst   => rst,
      start => start,
      done  => done,
      a     => a,
      b     => b,
      c     => c
    );

  clk <= not clk after 5 ns;

  process
  begin
    -- Reset
    rst <= '1';
    wait for 20 ns;
    rst <= '0';

    -- N?p d? li?u test
    for i in 0 to N-1 loop
      a(i) <= to_signed(i, COEFF_WIDTH);
      b(i) <= to_signed(2*i, COEFF_WIDTH);
    end loop;

    start <= '1';
    wait for 10 ns;
    start <= '0';

    wait until done = '1';
    wait for 20 ns;

    report "=== POLY_SUB RESULT ===";
    for i in 0 to 7 loop
      report "c(" & integer'image(i) & ") = " & integer'image(to_integer(c(i)));
    end loop;

    wait;
  end process;
end architecture sim;
