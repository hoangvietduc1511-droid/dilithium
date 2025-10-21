library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity polyveck_freeze is
    generic (
        K : natural := 4;    -- s? poly trong vector
        N : natural := 256   -- s? coefficient trong poly
    );
    port(
        clk   : in  std_logic;
        v_in  : in  polyvec_t(0 to K-1, 0 to N-1);
        v_out : out polyvec_t(0 to K-1, 0 to N-1)
    );
end entity;

architecture Behavioral of polyveck_freeze is

    -- Signal trung gian 1D ?? x? lý t?ng poly
    signal poly_in  : poly_t(0 to N-1);
    signal poly_out : poly_t(0 to N-1);

begin

    -- Process ??ng b? v?i clock
    process(clk)
    begin
        if rising_edge(clk) then

            -- Duy?t t?t c? poly trong vector
            for i in 0 to K-1 loop

                -- Copy d? li?u poly th? i t? v_in sang poly_in
                for j in 0 to N-1 loop
                    poly_in(j) <= v_in(i,j);
                end loop;

                -- X? lý t?ng coefficient b?ng reduce32 (gi?ng poly_freeze)
                for j in 0 to N-1 loop
                    poly_out(j) <= reduce32(poly_in(j));
                end loop;

                -- Copy k?t qu? tr? l?i v_out
                for j in 0 to N-1 loop
                    v_out(i,j) <= poly_out(j);
                end loop;

            end loop;

        end if;
    end process;

end architecture;
