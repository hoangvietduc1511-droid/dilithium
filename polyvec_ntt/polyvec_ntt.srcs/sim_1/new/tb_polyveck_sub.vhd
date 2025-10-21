library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_polyveck_sub is
end tb_polyveck_sub;

architecture sim of tb_polyveck_sub is
  constant N : natural := 8;   -- gi?m N ?? d? quan sát
  constant K : natural := 2;

  signal clk, rst, start, done : std_logic := '0';
  signal u, v, w : polyvec_t(0 to K-1, 0 to N-1);

begin
  uut: entity work.polyveck_sub
    generic map(N => N, K => K)
    port map(clk => clk, rst => rst, start => start, done => done, u => u, v => v, w => w);

  clk <= not clk after 5 ns;

  process
  begin
    rst <= '1'; wait for 10 ns; rst <= '0';
    -- kh?i t?o u và v
    for i in 0 to K-1 loop
      for j in 0 to N-1 loop
        u(i, j) <= to_signed(j + i*10 + 1, 32);
        v(i, j) <= to_signed((j + 1) * 2, 32);
      end loop;
    end loop;

    wait for 10 ns;
    start <= '1'; wait for 10 ns; start <= '0';
    wait until done = '1';
    wait for 20 ns;
    report "Simulation finished.";
    wait;
  end process;
end architecture;
