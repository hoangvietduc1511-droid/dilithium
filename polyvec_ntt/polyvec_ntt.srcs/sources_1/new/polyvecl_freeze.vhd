library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity polyvecl_freeze is
    generic (
        L : natural := 4;    -- s? poly trong vector (theo Dilithium)
        N : natural := 256   -- s? coefficient trong m?i poly
    );
    port(
        clk   : in  std_logic;
        l_in  : in  polyvec_t(0 to L-1, 0 to N-1);
        l_out : out polyvec_t(0 to L-1, 0 to N-1)
    );
end entity;

architecture Behavioral of polyvecl_freeze is

    -- Signal trung gian ?? x? lý t?ng poly (1D)
    signal poly_in  : poly_t(0 to N-1);
    signal poly_out : poly_t(0 to N-1);

begin

    -- Process ??ng b?
    process(clk)
    begin
        if rising_edge(clk) then

            -- Duy?t qua t?ng poly trong vector l
            for i in 0 to L-1 loop

                -- Copy t?ng h? s? c?a poly th? i t? l_in sang poly_in
                for j in 0 to N-1 loop
                    poly_in(j) <= l_in(i,j);
                end loop;

                -- Gi?m t?ng h? s? v? d?ng chu?n (freeze)
                for j in 0 to N-1 loop
                    poly_out(j) <= reduce32(poly_in(j));
                end loop;

                -- Copy k?t qu? ng??c l?i l_out
                for j in 0 to N-1 loop
                    l_out(i,j) <= poly_out(j);
                end loop;

            end loop;

        end if;
    end process;

end architecture;
