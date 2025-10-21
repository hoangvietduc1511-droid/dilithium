library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity poly_invntt_montgomery is
  generic ( N : natural := 256 );
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    start : in  std_logic;
    a_in  : in  poly_t(0 to N-1);
    done  : out std_logic;
    a_out : out poly_t(0 to N-1)
  );
end entity;

architecture behav of poly_invntt_montgomery is
  signal a_reg : poly_t(0 to N-1);
  signal busy  : std_logic := '0';
begin
  process(clk, reset)
  begin
    if reset = '1' then
      a_reg <= (others => (others => '0'));
      a_out <= (others => (others => '0'));
      done  <= '0';
      busy  <= '0';
    elsif rising_edge(clk) then
      if (start = '1') and (busy = '0') then
        a_reg <= a_in;
        busy  <= '1';
        done  <= '0';
      elsif busy = '1' then
        -- identity (thay b?ng inverse NTT + Montgomery multiply khi c?n)
        a_out <= a_reg;
        done  <= '1';
        busy  <= '0';
      else
        done <= '0';
      end if;
    end if;
  end process;
end architecture;
