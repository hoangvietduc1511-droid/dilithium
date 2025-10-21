library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

package montgomery_pkg is
  function montgomery_reduce(a : unsigned(63 downto 0)) return coeff_t;
end package montgomery_pkg;


package body montgomery_pkg is

  function montgomery_reduce(a : unsigned(63 downto 0)) return coeff_t is
    variable prod128 : unsigned(127 downto 0) := (others => '0');
    variable m32     : unsigned(31 downto 0)   := (others => '0');
    variable t64     : unsigned(63 downto 0)   := (others => '0');
    variable r32     : unsigned(31 downto 0)   := (others => '0');
    variable r32_mod : unsigned(31 downto 0)   := (others => '0');
  begin
    -- tmp128 = a * QINV_u
    prod128 := resize(a, 128) * resize(QINV_u, 128);

    -- m = low 32 bits
    m32 := prod128(31 downto 0);

    -- t = a + m * Q
    t64 := a + (resize(m32, 64) * to_unsigned(Q, 64));

    -- r = t >> 32
    r32 := t64(63 downto 32);

    -- single subtraction if >= Q
    if r32 >= to_unsigned(Q, 32) then
      r32_mod := r32 - to_unsigned(Q, 32);
    else
      r32_mod := r32;
    end if;

    return signed(r32_mod);
  end function;

end package body;
