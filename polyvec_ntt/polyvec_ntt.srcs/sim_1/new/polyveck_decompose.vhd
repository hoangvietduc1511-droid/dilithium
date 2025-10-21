-- polyveck_decompose.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Package ??nh ngh?a record và type 2D array
package polyveck_pkg is
    constant K : integer := 4;   -- s? polynomials
    constant N : integer := 256; -- s? coefficients m?i polynomial

    -- Record ch?a k?t qu? decompose
    type decompose_out is record
        a0 : unsigned(31 downto 0);
        a1 : unsigned(3 downto 0);
    end record;

    -- 2D array cho v_in, v0_out, v1_out
    type coeff_array32 is array(0 to K-1, 0 to N-1) of unsigned(31 downto 0);
    type coeff_array4  is array(0 to K-1, 0 to N-1) of unsigned(3 downto 0);
end package;

-- Entity
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.polyveck_pkg.all;

entity polyveck_decompose is
    port(
        clk    : in  std_logic;
        rst    : in  std_logic;
        v_in   : in  coeff_array32;
        v0_out : out coeff_array32;
        v1_out : out coeff_array4
    );
end polyveck_decompose;

architecture Behavioral of polyveck_decompose is
    constant Q     : integer := 8380417;
    constant ALPHA : integer := (Q-1)/16;

    -- Function decompose tr? record
    function decompose(a_in : unsigned(31 downto 0)) return decompose_out is
        variable a  : unsigned(31 downto 0);
        variable t  : signed(31 downto 0);
        variable u  : signed(31 downto 0);
        variable res: decompose_out;
    begin
        -- Step 1: centralized remainder mod ALPHA
        t := signed(a_in and x"7FFFF");
        t := t + shift_left(signed(a_in(31 downto 19)), 9);
        t := t - (ALPHA/2 + 1);
        if t(31) = '1' then
            t := t + ALPHA;
        end if;
        t := t - (ALPHA/2 -1);
        a := a_in - unsigned(t);

        -- Step 2: divide by ALPHA
        u := signed(a) - 1;
        u := shift_right(u,31);
        a := shift_right(a,19) +1;
        if u(0) = '1' then
            a := a - 1;
        end if;

        -- Step 3: border case
        res.a0 := to_unsigned(Q,32) + unsigned(t) - shift_right(a,4);
        res.a1 := a(3 downto 0);

        return res;
    end function;

begin
    process(clk)
        variable tmp : decompose_out;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                for i in 0 to K-1 loop
                    for j in 0 to N-1 loop
                        v0_out(i,j) <= (others=>'0');
                        v1_out(i,j) <= (others=>'0');
                    end loop;
                end loop;
            else
                for i in 0 to K-1 loop
                    for j in 0 to N-1 loop
                        tmp := decompose(v_in(i,j));
                        v0_out(i,j) <= tmp.a0;
                        v1_out(i,j) <= tmp.a1;
                    end loop;
                end loop;
            end if;
        end if;
    end process;
end Behavioral;
