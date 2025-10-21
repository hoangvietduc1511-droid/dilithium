--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--package poly_pkg is
--  constant COEFF_WIDTH : integer := 32;
--  subtype coeff_t is signed(COEFF_WIDTH-1 downto 0);

--  -- M?t ?a th?c (array 1D)
--  type poly_t is array (natural range <>) of coeff_t;

--  -- Vector K ?a th?c, m?i ?a th?c N h? s?
--  type polyvec_t is array (natural range <>, natural range <>) of coeff_t;
--end package;

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--package poly_pkg is
--  --------------------------------------------------------------------
--  -- C?u hình h? s?
--  --------------------------------------------------------------------
--  constant COEFF_WIDTH : integer := 32;
--  subtype coeff_t is signed(COEFF_WIDTH-1 downto 0);

--  --------------------------------------------------------------------
--  -- ??nh ngh?a các ki?u d? li?u
--  --------------------------------------------------------------------
--  -- M?t ?a th?c (array 1D)
--  type poly_t is array (natural range <>) of coeff_t;

--  -- Vector K ?a th?c (array 2D: s? ?a th?c x s? h? s?)
--  type polyvec_t is array (natural range <>, natural range <>) of coeff_t;

--  --------------------------------------------------------------------
--  -- Các h?ng s? toán h?c cho Dilithium
--  --------------------------------------------------------------------
--  -- Modulus Q và h?ng s? ngh?ch ??o Montgomery
--  constant Q    : integer := 8380417;                 -- Q trong Dilithium
--  constant QINV : integer := 4236238847;              -- -q^(-1) mod 2^32

--  --------------------------------------------------------------------
--  -- Hàm reduce32 (gi?m h? s? v? modulo Q)
--  --------------------------------------------------------------------
--  function reduce32(a : coeff_t) return coeff_t;

--  --------------------------------------------------------------------
--  -- Hàm montgomery_reduce: (a * 2^(-32)) mod Q
--  -- Input: 64-bit, Output: coeff_t (32-bit signed)
--  --------------------------------------------------------------------
--  function montgomery_reduce(a : unsigned(63 downto 0)) return coeff_t;

--end package;

--package body poly_pkg is

--  --------------------------------------------------------------------
--  -- reduce32: ??a v? trong [-Q/2, Q/2]
--  --------------------------------------------------------------------
--  function reduce32(a : coeff_t) return coeff_t is
--    variable t : integer;
--  begin
--    t := to_integer(a) mod Q;
--    if t > Q/2 then
--      t := t - Q;
--    elsif t < -Q/2 then
--      t := t + Q;
--    end if;
--    return to_signed(t, COEFF_WIDTH);
--  end function;

--  --------------------------------------------------------------------
--  -- montgomery_reduce
--  --------------------------------------------------------------------
--  function montgomery_reduce(a : unsigned(63 downto 0)) return coeff_t is
--    variable a_int : unsigned(63 downto 0) := a;
--    variable t     : unsigned(63 downto 0);
--    variable res   : integer;
--  begin
--    -- t = (a * QINV) & (2^32-1)
--    t := (a_int * to_unsigned(QINV, 64));
--    t := t and x"00000000FFFFFFFF";  -- l?y 32 bit th?p
--    -- t = t * Q
--    t := t * to_unsigned(Q, 64);
--    -- t = a + t
--    t := a_int + t;
--    -- res = t >> 32
--    res := to_integer(shift_right(t, 32));
--    return to_signed(res, COEFF_WIDTH);
--  end function;

--end package body;

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--package poly_pkg is
--  constant COEFF_WIDTH : integer := 32;
--  constant Q     : integer := 8380417; -- Q c?a Dilithium
--  constant QINV  : integer := 4236238847; -- -Q^{-1} mod 2^32

--  subtype coeff_t is signed(COEFF_WIDTH-1 downto 0);

--  -- M?t ?a th?c (array 1D)
--  type poly_t is array (natural range <>) of coeff_t;

--  -- Vector K ?a th?c, m?i ?a th?c N h? s?
--  type polyvec_t is array (natural range <>, natural range <>) of coeff_t;

--  -- Hàm reduce modulo Q
--  function reduce32(a : coeff_t) return coeff_t;

--  -- Montgomery reduce: input a 64-bit unsigned
--  function montgomery_reduce(a : unsigned(63 downto 0)) return coeff_t;

--end package;


--package body poly_pkg is
--  function reduce32(a : coeff_t) return coeff_t is
--    variable res : integer;
--  begin
--    res := to_integer(a) mod Q;
--    if res > Q/2 then
--      res := res - Q;
--    elsif res < -Q/2 then
--      res := res + Q;
--    end if;
--    return to_signed(res, COEFF_WIDTH);
--  end function;

--  function montgomery_reduce(a : unsigned(63 downto 0)) return coeff_t is
--    variable t   : unsigned(63 downto 0);
--    variable res : integer;
--  begin
--    -- t = (a * QINV) & (2^32 - 1)
--    t := (a * to_unsigned(QINV, 64));
--    t := t and x"00000000FFFFFFFF";
--    -- t = a + t*Q
--    t := a + (t * to_unsigned(Q, 64));
--    -- res = t >> 32
--    res := to_integer(shift_right(t, 32));
--    return to_signed(res, COEFF_WIDTH);
--  end function;
--end package body;

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--package poly_pkg is
--  ----------------------------------------------------------------------------
--  -- Configuration
--  ----------------------------------------------------------------------------
--  constant COEFF_WIDTH : natural := 32;

--  ----------------------------------------------------------------------------
--  -- Types
--  ----------------------------------------------------------------------------
--  subtype coeff_t is signed(COEFF_WIDTH-1 downto 0);

--  -- poly_t UNCONSTRAINED so entities can use poly_t(0 to N-1)
--  type poly_t is array (natural range <>) of coeff_t;

--  type polyvec_t is array (natural range <>, natural range <>) of coeff_t;

--  ----------------------------------------------------------------------------
--  -- Constants (CRYSTALS-Dilithium)
--  ----------------------------------------------------------------------------
--  constant Q      : integer := 8380417;
--  -- QINV as 32-bit unsigned (decimal 4236238847 = 0xFC7FDFFF)
--  constant QINV_u : unsigned(31 downto 0) := x"FC7FDFFF";

--  ----------------------------------------------------------------------------
--  -- API
--  ----------------------------------------------------------------------------
--  -- montgomery_reduce: input 64-bit unsigned product, output coeff_t (signed 32)
--  function montgomery_reduce(a : unsigned(63 downto 0)) return coeff_t;

--  -- final centering reduce32
--  function reduce32(a : coeff_t) return coeff_t;

--  -- simple product mod Q for testing (safe integer arithmetic for small tests)
--  function mul_mod(a : coeff_t; b : coeff_t) return coeff_t;

--end package poly_pkg;


--package body poly_pkg is

--  ----------------------------------------------------------------------------
--  -- montgomery_reduce
--  ----------------------------------------------------------------------------
--  function montgomery_reduce(a : unsigned(63 downto 0)) return coeff_t is
--    variable prod128 : unsigned(127 downto 0) := (others => '0');
--    variable m32     : unsigned(31 downto 0)   := (others => '0');
--    variable t64     : unsigned(63 downto 0)   := (others => '0');
--    variable r32     : unsigned(31 downto 0)   := (others => '0');
--    variable r32_mod : unsigned(31 downto 0)   := (others => '0');
--  begin
--    -- tmp128 = a * QINV_u
--    prod128 := resize(a, 128) * resize(QINV_u, 128);

--    -- m = low 32 bits
--    m32 := prod128(31 downto 0);

--    -- t = a + m * Q
--    t64 := a + (resize(m32, 64) * to_unsigned(Q, 64));

--    -- r = t >> 32
--    r32 := t64(63 downto 32);

--    -- single subtraction if >= Q
--    if r32 >= to_unsigned(Q, 32) then
--      r32_mod := r32 - to_unsigned(Q, 32);
--    else
--      r32_mod := r32;
--    end if;

--    return signed(r32_mod);
--  end function;

--  ----------------------------------------------------------------------------
--  -- reduce32: center into [-Q/2, Q/2]
--  ----------------------------------------------------------------------------
--  function reduce32(a : coeff_t) return coeff_t is
--    variable t : integer;
--  begin
--    t := to_integer(a) mod Q;
--    if t < 0 then
--      t := t + Q;
--    end if;
--    if t > Q/2 then
--      t := t - Q;
--    end if;
--    return to_signed(t, COEFF_WIDTH);
--  end function;

--  ----------------------------------------------------------------------------
--  -- mul_mod: small helper for test (a*b mod Q)
--  ----------------------------------------------------------------------------
--  function mul_mod(a : coeff_t; b : coeff_t) return coeff_t is
--    variable pa : integer := to_integer(a);
--    variable pb : integer := to_integer(b);
--    variable prod : integer := pa * pb;
--    variable r : integer := prod mod Q;
--  begin
--    if r < 0 then r := r + Q; end if;
--    return to_signed(r, COEFF_WIDTH);
--  end function;

--end package body;


    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.NUMERIC_STD.ALL;
    
    package poly_pkg is
      ----------------------------------------------------------------------------
      -- Configuration
      ----------------------------------------------------------------------------
      constant COEFF_WIDTH : natural := 32;
      constant N           : natural := 256;  -- s? h? s? trong 1 ?a th?c
      constant K           : natural := 4;    -- s? poly trong polyveck
      constant L           : natural := 4;    -- s? poly trong polyvecl
    
      ----------------------------------------------------------------------------
      -- Types
      ----------------------------------------------------------------------------
      subtype coeff_t is signed(COEFF_WIDTH-1 downto 0);
    
      -- 1 polynomial
      type poly_t is array (0 to N-1) of coeff_t;
    
      -- vector L (polyvecl)
      type polyvecl_t is array (0 to L-1) of poly_t;
    
      -- vector K (polyveck)
      type polyveck_t is array (0 to K-1) of poly_t;
    
      -- flat coefficient arrays (d? mapping c?ng)
      type coeff_array32 is array (0 to 31) of coeff_t;  -- ví d? cho 32 h? s?
      type coeff_array4  is array (0 to 3)  of coeff_t;  -- ví d? cho 4 h? s?
      type coeff_array256 is array (0 to 255) of coeff_t;
    
      -- polyvec generic 2D
      type polyvec_t is array (natural range <>, natural range <>) of coeff_t;
    
      ----------------------------------------------------------------------------
      -- Constants (CRYSTALS-Dilithium)
      ----------------------------------------------------------------------------
      constant Q      : integer := 8380417;
      constant QINV_u : unsigned(31 downto 0) := x"FC7FDFFF"; -- 4236238847
    
      ----------------------------------------------------------------------------
      -- Functions
      ----------------------------------------------------------------------------
      -- montgomery_reduce: input 64-bit unsigned product, output coeff_t (signed 32)
      function montgomery_reduce(a : unsigned(63 downto 0)) return coeff_t;
    
      -- final centering reduce32
      function reduce32(a : coeff_t) return coeff_t;
    
      -- simple product mod Q for testing (safe integer arithmetic)
      function mul_mod(a : coeff_t; b : coeff_t) return coeff_t;
    
      ----------------------------------------------------------------------------
      -- Helper for packing polyvec to std_logic_vector(511 downto 0)
      ----------------------------------------------------------------------------
      function polyvec_to_sv512(vec : polyvec_t) return std_logic_vector;
    
    end package poly_pkg;
    
    -------------------------------------------------------------------------------
    -- Package Body
    -------------------------------------------------------------------------------
    package body poly_pkg is
    
      ----------------------------------------------------------------------------
      -- montgomery_reduce
      ----------------------------------------------------------------------------
      function montgomery_reduce(a : unsigned(63 downto 0)) return coeff_t is
        variable prod128 : unsigned(127 downto 0) := (others => '0');
        variable m32     : unsigned(31 downto 0)   := (others => '0');
        variable t64     : unsigned(63 downto 0)   := (others => '0');
        variable r32     : unsigned(31 downto 0)   := (others => '0');
        variable r32_mod : unsigned(31 downto 0)   := (others => '0');
      begin
        prod128 := resize(a, 128) * resize(QINV_u, 128);
        m32 := prod128(31 downto 0);
        t64 := a + (resize(m32, 64) * to_unsigned(Q, 64));
        r32 := t64(63 downto 32);
    
        if r32 >= to_unsigned(Q, 32) then
          r32_mod := r32 - to_unsigned(Q, 32);
        else
          r32_mod := r32;
        end if;
    
        return signed(r32_mod);
      end function;
    
      ----------------------------------------------------------------------------
      -- reduce32: center into [-Q/2, Q/2]
      ----------------------------------------------------------------------------
      function reduce32(a : coeff_t) return coeff_t is
        variable t : integer;
      begin
        t := to_integer(a) mod Q;
        if t < 0 then
          t := t + Q;
        end if;
        if t > Q/2 then
          t := t - Q;
        end if;
        return to_signed(t, COEFF_WIDTH);
      end function;
    
      ----------------------------------------------------------------------------
      -- mul_mod: small helper
      ----------------------------------------------------------------------------
      function mul_mod(a : coeff_t; b : coeff_t) return coeff_t is
        variable pa : integer := to_integer(a);
        variable pb : integer := to_integer(b);
        variable prod : integer := pa * pb;
        variable r : integer := prod mod Q;
      begin
        if r < 0 then r := r + Q; end if;
        return to_signed(r, COEFF_WIDTH);
      end function;
    
      ----------------------------------------------------------------------------
      -- polyvec_to_sv512: flatten one polyvec (take lowest 512 bits)
      ----------------------------------------------------------------------------
      function polyvec_to_sv512(vec : polyvec_t) return std_logic_vector is
        variable tmp : std_logic_vector(511 downto 0) := (others => '0');
      begin
        -- Ch? demo: copy 16 h? s? ??u tiên m?i h? s? 32 bit
        for i in 0 to 15 loop
          tmp(511 - i*32 downto 480 - i*32) := std_logic_vector(vec(0, i));
        end loop;
        return tmp;
      end function;
    
    end package body;
    




