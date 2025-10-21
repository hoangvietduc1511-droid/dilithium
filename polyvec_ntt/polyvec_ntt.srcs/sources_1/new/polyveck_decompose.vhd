-- polyveck_decompose.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.polyveck_pkg.all;

entity polyveck_decompose is
    port(
        clk    : in  std_logic;
        rst    : in  std_logic;
        v_in   : in  coeff_array32;   -- type t? polyveck_pkg (K x N)
        v0_out : out coeff_array32;
        v1_out : out coeff_array4
    );
end entity;

architecture Behavioral of polyveck_decompose is

    -- record tr? v? a0,a1
    type decompose_out is record
        a0 : unsigned(31 downto 0);
        a1 : unsigned(3 downto 0);
    end record;

    -- Hàm decompose: th?c hi?n các b??c nh? trong C nh?ng dùng integer ?? tránh r?c r?i ki?u
    function decompose(a_in : unsigned(31 downto 0)) return decompose_out is
        variable ai     : integer;
        variable t      : integer;
        variable a_adj  : integer;
        variable A      : integer;
        variable a0_int : integer;
        variable a1_int : integer;
        variable res    : decompose_out;
        constant MASK19 : integer := 2**19; -- 524288
    begin
        -- chuy?n vào integer
        ai := to_integer(a_in);

        -- Step 1: centralized remainder mod ALPHA (cùng logic nh? C)
        t := ai mod MASK19;                        -- a & 0x7FFFF
        t := t + ((ai / MASK19) * 512);           -- (a >> 19) << 9  <=> (a/2^19)*512
        t := t - (ALPHA/2 + 1);
        if t < 0 then
            t := t + ALPHA;                       -- emulate (t>>31) & ALPHA
        end if;
        t := t - (ALPHA/2 - 1);
        a_adj := ai - t;

        -- Step 2: divide by ALPHA (emulate C edge-case when a_adj==0)
        if a_adj = 0 then
            A := 0;
        else
            A := (a_adj / MASK19) + 1;            -- (a >> 19) + 1
        end if;

        -- Step 3: border case (a0 = Q + t - (A >> 4); a1 = A & 0xF)
        a0_int := Q + t - (A / 16);               -- (A >> 4) same as A/16
        a1_int := A mod 16;

        -- convert a0_int,a1_int sang ki?u tr? v?
        -- a0_int có th? âm (ví d? -1), dùng to_signed tr??c khi cast v? unsigned ?? gi? hai's complement
        res.a0 := unsigned(to_signed(a0_int, 32));
        res.a1 := to_unsigned(a1_int, 4);

        return res;
    end function;

begin

    process(clk)
        variable dec : decompose_out;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- reset toàn b? outputs
                v0_out <= (others => (others => (others => '0')));
                v1_out <= (others => (others => (others => '0')));
            else
                -- cho t?ng h? s? g?i decompose và ghi output
                for i in 0 to K-1 loop
                    for j in 0 to N-1 loop
                        dec := decompose(v_in(i,j));
                        v0_out(i,j) <= dec.a0;
                        v1_out(i,j) <= dec.a1;
                    end loop;
                end loop;
            end if;
        end if;
    end process;

end architecture;
