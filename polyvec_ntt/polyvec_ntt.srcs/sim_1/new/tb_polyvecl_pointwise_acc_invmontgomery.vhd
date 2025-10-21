library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity polyvecl_pointwise_acc_invmontgomery is
  generic (
    N : integer := 256;  -- s? h? s? m?i ?a th?c
    L : integer := 4     -- s? ?a th?c trong vector
  );
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    start : in  std_logic;
    u_in  : in  polyvec_t(0 to L-1, 0 to N-1); -- input vector u
    v_in  : in  polyvec_t(0 to L-1, 0 to N-1); -- input vector v
    done  : out std_logic;
    w_out : out poly_t(0 to N-1)               -- output poly
  );
end entity;

architecture rtl of polyvecl_pointwise_acc_invmontgomery is
begin

  process(clk, reset)
    variable acc : coeff_t;
    variable temp : coeff_t;
  begin
    if reset = '1' then
      w_out <= (others => (others => '0'));
      done  <= '0';

    elsif rising_edge(clk) then
      if start = '1' then
        -- Tính tích ch?p t?ng h? s?
        for i in 0 to N-1 loop
          acc := (others => '0');
          for l in 0 to L-1 loop
            temp := montgomery_reduce(resize(u_in(l,i), 64) * resize(v_in(l,i), 64));
            acc  := acc + temp;
          end loop;
          w_out(i) <= acc;
        end loop;
        done <= '1';
      else
        done <= '0';
      end if;
    end if;
  end process;

end architecture;
