library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_poly_ntt is
end entity;

architecture sim of tb_poly_ntt is
  constant N : natural := 8; -- gi?m nh? ?? mô ph?ng nhanh
  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';
  signal start : std_logic := '0';
  signal done  : std_logic;
  signal a_in  : poly_t(0 to N-1);
  signal a_out : poly_t(0 to N-1);
begin
  -- clock 10 ns
  clk <= not clk after 5 ns;

  -- DUT
  uut: entity work.poly_ntt
    generic map ( N => N )
    port map (
      clk   => clk,
      reset => reset,
      start => start,
      a_in  => a_in,
      done  => done,
      a_out => a_out
    );

  -- stimulus
  process
  begin
    -- reset
    reset <= '1';
    wait for 20 ns;
    reset <= '0';

    -- t?o input = [0,1,2,...,7]
    for i in 0 to N-1 loop
      a_in(i) <= to_signed(i, 32);
    end loop;

    -- b?t ??u
    start <= '1';
    wait for 10 ns;
    start <= '0';

    -- ch? done
    wait until done = '1';
    wait for 10 ns;

    -- hi?n th? k?t qu?
    for i in 0 to N-1 loop
      report "a_out(" & integer'image(i) & ") = " & integer'image(to_integer(a_out(i)));
    end loop;

    wait;
  end process;
end architecture;
