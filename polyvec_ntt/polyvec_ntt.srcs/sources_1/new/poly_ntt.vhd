library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity poly_ntt is
  generic (
    N : natural := 256
  );
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    start : in  std_logic;
    a_in  : in  poly_t(0 to N-1);
    done  : out std_logic;
    a_out : out poly_t(0 to N-1)
  );
end entity;

architecture rtl of poly_ntt is
  signal busy : std_logic := '0';
begin
  process(clk, reset)
  begin
    if reset = '1' then
      busy  <= '0';
      done  <= '0';
      a_out <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if start = '1' and busy = '0' then
        busy  <= '1';
        a_out <= a_in;  -- mock: ch? copy input sang output
        done  <= '1';
      else
        done <= '0';
        busy <= '0';
      end if;
    end if;
  end process;
end architecture;
