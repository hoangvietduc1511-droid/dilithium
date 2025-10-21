--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

---- Khai báo type 2D ngoài entity
--package polyveck_pkg is
--    generic (K : integer := 4; N : integer := 256);
--    type coeff_array32 is array (0 to K-1, 0 to N-1) of unsigned(31 downto 0);
--    type coeff_array4  is array (0 to K-1, 0 to N-1) of unsigned(3 downto 0);
--end package;

-- polyveck_pkg.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package polyveck_pkg is
    ----------------------------------------------------------------
    -- Constants
    ----------------------------------------------------------------
    constant K : integer := 2;  -- vector length
    constant N : integer := 4;  -- polynomial degree
    constant ALPHA : integer := (8380417 / 16); -- Q-1/16
    constant Q : integer := 8380417;

    ----------------------------------------------------------------
    -- Type definitions
    ----------------------------------------------------------------
    subtype coeff32 is unsigned(31 downto 0);
    subtype coeff4  is unsigned(3 downto 0);

    type coeff_array32 is array(0 to K-1, 0 to N-1) of coeff32;
    type coeff_array4  is array(0 to K-1, 0 to N-1) of coeff4;

end package polyveck_pkg;
