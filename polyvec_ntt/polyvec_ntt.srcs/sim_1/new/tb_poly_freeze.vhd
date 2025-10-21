library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_poly_freeze is
end entity;

architecture sim of tb_poly_freeze is

    -- Parameters
    constant N : natural := 16; -- dùng N nh? ?? test d? quan sát

    -- Signals
    signal clk   : std_logic := '0';
    signal a_in  : poly_t(0 to N-1);
    signal a_out : poly_t(0 to N-1);

begin

    -- Clock generation: 10 ns period
    clk <= not clk after 5 ns;

    -- Instantiate DUT
    DUT: entity work.poly_freeze
        generic map(
            N => N
        )
        port map(
            clk   => clk,
            a_in  => a_in,
            a_out => a_out
        );

    -- Test process
    process
    begin
        -- Initialize input poly with large values to test reduce32
        for i in 0 to N-1 loop
            a_in(i) <= to_signed((i+1)*1000000, COEFF_WIDTH); -- ví d? giá tr? l?n
        end loop;

        -- Wait some clock cycles
        wait for 200 ns;

        -- Test negative values
        for i in 0 to N-1 loop
            a_in(i) <= to_signed(-((i+1)*500000), COEFF_WIDTH);
        end loop;

        wait for 200 ns;

        -- Test random small values
        for i in 0 to N-1 loop
            a_in(i) <= to_signed(i*12345, COEFF_WIDTH);
        end loop;

        wait for 200 ns;

        -- Stop simulation
        wait;
    end process;

end architecture;
