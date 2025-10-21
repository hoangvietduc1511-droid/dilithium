library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.poly_pkg.all;  -- montgomery_reduce must be declared in poly_pkg

entity tb_montgomery_reduce is
end entity;

architecture behavior of tb_montgomery_reduce is
begin
  process
    variable a32     : unsigned(31 downto 0);
    variable b32     : unsigned(31 downto 0);
    variable a64     : unsigned(63 downto 0);
    variable prod128 : unsigned(127 downto 0);
    variable m32     : unsigned(31 downto 0);
    variable t64     : unsigned(63 downto 0);
    variable r32     : unsigned(31 downto 0);
    variable r32_mod : unsigned(31 downto 0);
    variable res     : coeff_t;
    variable expect  : coeff_t;
  begin
    -------------------------------------------------------------
    -- Test case 1
    -------------------------------------------------------------
    a32 := to_unsigned(12345, 32);
    b32 := to_unsigned(67890, 32);

    -- product of two 32-bit unsigned => 64-bit unsigned
    a64 := a32 * b32;

    -- call DUT function
    res := montgomery_reduce(a64);

    -- compute reference:
    -- prod128 = resize(a64,128) * resize(QINV_u,128)
    prod128 := resize(a64,128) * resize(QINV_u,128);
    m32 := prod128(31 downto 0);
    t64 := a64 + (resize(m32,64) * to_unsigned(Q,64));
    r32 := t64(63 downto 32);
    if r32 >= to_unsigned(Q,32) then
      r32_mod := r32 - to_unsigned(Q,32);
    else
      r32_mod := r32;
    end if;
    expect := signed(r32_mod);

    report "TC1: a=" & integer'image(to_integer(a32)) &
           " b=" & integer'image(to_integer(b32)) &
           " a*b(low32)=" & integer'image(to_integer(a64(31 downto 0))) &
           " montgomery_reduce=" & integer'image(to_integer(res)) &
           " expected=" & integer'image(to_integer(expect));

    -------------------------------------------------------------
    -- Test case 2 (small)
    -------------------------------------------------------------
    a32 := to_unsigned(3, 32);
    b32 := to_unsigned(10, 32);
    a64 := a32 * b32;
    res  := montgomery_reduce(a64);

    prod128 := resize(a64,128) * resize(QINV_u,128);
    m32 := prod128(31 downto 0);
    t64 := a64 + (resize(m32,64) * to_unsigned(Q,64));
    r32 := t64(63 downto 32);
    if r32 >= to_unsigned(Q,32) then
      r32_mod := r32 - to_unsigned(Q,32);
    else
      r32_mod := r32;
    end if;
    expect := signed(r32_mod);

    report "TC2: a=3 b=10 montgomery_reduce=" & integer'image(to_integer(res)) &
           " expected=" & integer'image(to_integer(expect));

    -------------------------------------------------------------
    -- Test case 3 (bigger)
    -------------------------------------------------------------
    a32 := to_unsigned(400000, 32);
    b32 := to_unsigned(5000, 32);
    a64 := a32 * b32;
    res  := montgomery_reduce(a64);

    prod128 := resize(a64,128) * resize(QINV_u,128);
    m32 := prod128(31 downto 0);
    t64 := a64 + (resize(m32,64) * to_unsigned(Q,64));
    r32 := t64(63 downto 32);
    if r32 >= to_unsigned(Q,32) then
      r32_mod := r32 - to_unsigned(Q,32);
    else
      r32_mod := r32;
    end if;
    expect := signed(r32_mod);

    report "TC3: a=" & integer'image(to_integer(a32)) &
           " b=" & integer'image(to_integer(b32)) &
           " montgomery_reduce=" & integer'image(to_integer(res)) &
           " expected=" & integer'image(to_integer(expect));

    -------------------------------------------------------------
    -- Test case 4 (edge-ish)
    -------------------------------------------------------------
    a32 := to_unsigned(65535, 32);
    b32 := to_unsigned(65535, 32);
    a64 := a32 * b32;
    res  := montgomery_reduce(a64);

    prod128 := resize(a64,128) * resize(QINV_u,128);
    m32 := prod128(31 downto 0);
    t64 := a64 + (resize(m32,64) * to_unsigned(Q,64));
    r32 := t64(63 downto 32);
    if r32 >= to_unsigned(Q,32) then
      r32_mod := r32 - to_unsigned(Q,32);
    else
      r32_mod := r32;
    end if;
    expect := signed(r32_mod);

    report "TC4: a=65535 b=65535 montgomery_reduce=" & integer'image(to_integer(res)) &
           " expected=" & integer'image(to_integer(expect));

    wait;
  end process;
end architecture;
