library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity poly_sub is
  generic (
    N : natural := 256  -- s? h? s? m?i ?a th?c
  );
  port(
    clk   : in  std_logic;
    rst   : in  std_logic;
    start : in  std_logic;
    done  : out std_logic;
    a, b  : in  poly_t(0 to N-1);
    c     : out poly_t(0 to N-1)
  );
end entity poly_sub;

architecture Behavioral of poly_sub is
  signal i      : integer range 0 to N := 0;
  signal busy   : std_logic := '0';
  signal c_reg  : poly_t(0 to N-1) := (others => (others => '0'));
begin

  process(clk, rst)
  begin
    if rst = '1' then
      i     <= 0;
      busy  <= '0';
      done  <= '0';
      c_reg <= (others => (others => '0'));

    elsif rising_edge(clk) then
      if start = '1' and busy = '0' then
        -- B?t ??u quá trình tr?
        i     <= 0;
        busy  <= '1';
        done  <= '0';
      elsif busy = '1' then
        -- c[i] = a[i] + 2*Q - b[i]
        c_reg(i) <= signed(a(i)) + to_signed(2*Q, COEFF_WIDTH) - signed(b(i));

        if i = N-1 then
          busy <= '0';
          done <= '1';
        else
          i <= i + 1;
        end if;
      else
        done <= '0';
      end if;
    end if;
  end process;

  c <= c_reg;

end architecture Behavioral;
