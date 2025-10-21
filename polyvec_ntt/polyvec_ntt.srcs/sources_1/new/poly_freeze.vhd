library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity poly_freeze is
    generic (
        N : natural := 256  -- s? coefficient trong poly
    );
    port(
        clk   : in  std_logic;
        a_in  : in  poly_t(0 to N-1);
        a_out : out poly_t(0 to N-1)
    );
end entity;

architecture Behavioral of poly_freeze is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            for j in 0 to N-1 loop
                -- Dùng reduce32 t? package ?? freeze coefficient
                a_out(j) <= reduce32(a_in(j));
            end loop;
        end if;
    end process;
end architecture;
