-- ===================================================================
-- File: polyveck_add.vhd
-- Description: C?ng hai vector ?a th?c (polyveck)
-- Không th?c hi?n gi?m modulo
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity polyveck_add is
  generic (
    K : natural := 4;   -- s? l??ng ?a th?c trong vector
    N : natural := 256  -- s? h? s? trong m?i ?a th?c
  );
  port (
    u_in  : in  polyvec_t(0 to K-1, 0 to N-1);
    v_in  : in  polyvec_t(0 to K-1, 0 to N-1);
    w_out : out polyvec_t(0 to K-1, 0 to N-1)
  );
end entity polyveck_add;

architecture rtl of polyveck_add is
begin

  process(u_in, v_in)
  begin
    for i in 0 to K-1 loop
      for j in 0 to N-1 loop
        w_out(i, j) <= u_in(i, j) + v_in(i, j);
      end loop;
    end loop;
  end process;

end architecture rtl;
