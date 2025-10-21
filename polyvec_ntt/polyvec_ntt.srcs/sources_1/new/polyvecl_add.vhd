-- ===================================================================
-- File: polyvecl_add.vhd
-- Description: Add two vectors of polynomials (no modular reduction)
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity polyvecl_add is
  generic (
    L : natural := 4;     -- s? l??ng ?a th?c trong vector
    N : natural := 256    -- s? h? s? trong m?i ?a th?c
  );
  port (
    u_in  : in  polyvec_t(0 to L-1, 0 to N-1);
    v_in  : in  polyvec_t(0 to L-1, 0 to N-1);
    w_out : out polyvec_t(0 to L-1, 0 to N-1)
  );
end entity polyvecl_add;

architecture rtl of polyvecl_add is
begin
  process(u_in, v_in)
  begin
    for i in 0 to L-1 loop
      for j in 0 to N-1 loop
        w_out(i, j) <= u_in(i, j) + v_in(i, j);
      end loop;
    end loop;
  end process;
end architecture rtl;
