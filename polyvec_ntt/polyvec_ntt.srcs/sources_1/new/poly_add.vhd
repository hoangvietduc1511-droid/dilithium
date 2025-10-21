-- ===================================================================
-- File: poly_add.vhd
-- ===================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity poly_add is
  generic (
    N : natural := 256  -- s? h? s? (có th? override t? ngoài)
  );
  port (
    a_in  : in  poly_t(0 to N-1);
    b_in  : in  poly_t(0 to N-1);
    c_out : out poly_t(0 to N-1)
  );
end entity poly_add;

architecture rtl of poly_add is
begin
  process(a_in, b_in)
  begin
    for i in 0 to N-1 loop
      c_out(i) <= a_in(i) + b_in(i);
    end loop;
  end process;
end architecture rtl;
