library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity polyveck_sub is
  generic (
    N : natural := 256;  -- s? h? s? m?i ?a th?c
    K : natural := 4     -- s? ?a th?c trong vector
  );
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    start : in  std_logic;
    done  : out std_logic;

    -- vector ?a th?c ??u vào / ??u ra
    u : in  polyvec_t(0 to K-1, 0 to N-1);  -- vector u
    v : in  polyvec_t(0 to K-1, 0 to N-1);  -- vector v
    w : out polyvec_t(0 to K-1, 0 to N-1)   -- k?t qu? w = u - v (không mod Q)
  );
end entity polyveck_sub;

architecture Behavioral of polyveck_sub is
  signal i     : integer range 0 to K-1 := 0;
  signal j     : integer range 0 to N-1 := 0;
  signal busy  : std_logic := '0';
  signal w_reg : polyvec_t(0 to K-1, 0 to N-1);
begin

  process(clk, rst)
  begin
    if rst = '1' then
      i     <= 0;
      j     <= 0;
      busy  <= '0';
      done  <= '0';
      w_reg <= (others => (others => (others => '0')));

    elsif rising_edge(clk) then
      if start = '1' and busy = '0' then
        -- b?t ??u phép tr?
        busy <= '1';
        done <= '0';
        i    <= 0;
        j    <= 0;

      elsif busy = '1' then
        -- w[i,j] = u[i,j] + 2*Q - v[i,j]
        w_reg(i, j) <= u(i, j) + to_signed(2 * Q, COEFF_WIDTH) - v(i, j);

        -- d?ch ch? s?
        if j = N-1 then
          j <= 0;
          if i = K-1 then
            busy <= '0';
            done <= '1';
            i    <= 0;
          else
            i <= i + 1;
          end if;
        else
          j <= j + 1;
        end if;

      else
        done <= '0';
      end if;
    end if;
  end process;

  -- output
  w <= w_reg;

end architecture Behavioral;
