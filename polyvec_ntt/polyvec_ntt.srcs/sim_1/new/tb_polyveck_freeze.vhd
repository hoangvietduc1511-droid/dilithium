library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_polyveck_freeze is
end entity;

architecture sim of tb_polyveck_freeze is

    -- Parameters
    constant K : natural := 4;
    constant N : natural := 256;

    -- Signals
    signal clk   : std_logic := '0';
    signal v_in  : polyvec_t(0 to K-1, 0 to N-1);
    signal v_out : polyvec_t(0 to K-1, 0 to N-1);

begin

    --------------------------------------------------------------------
    -- Clock generation: 10 ns period
    --------------------------------------------------------------------
    clk <= not clk after 5 ns;

    --------------------------------------------------------------------
    -- Instantiate DUT
    --------------------------------------------------------------------
    DUT: entity work.polyveck_freeze
        generic map(
            K => K,
            N => N
        )
        port map(
            clk   => clk,
            v_in  => v_in,
            v_out => v_out
        );

    --------------------------------------------------------------------
    -- Test process
    --------------------------------------------------------------------
    process
        variable val : integer;
    begin

        -- 1. Giá tr? l?n
        for i in 0 to K-1 loop
            for j in 0 to N-1 loop
                v_in(i,j) <= to_signed((i*100+j)*1000000, COEFF_WIDTH);
            end loop;
        end loop;
        wait for 2000 ns;

        -- In k?t qu? sau freeze
        for i in 0 to K-1 loop
            for j in 0 to N-1 loop
                val := to_integer(v_out(i,j));
                report "v_out(" & integer'image(i) & "," & integer'image(j) & ") = " & integer'image(val);
            end loop;
        end loop;

        -- 2. Giá tr? âm
        for i in 0 to K-1 loop
            for j in 0 to N-1 loop
                v_in(i,j) <= to_signed(-((i*50+j)*500000), COEFF_WIDTH);
            end loop;
        end loop;
        wait for 2000 ns;

        -- In k?t qu?
        for i in 0 to K-1 loop
            for j in 0 to N-1 loop
                val := to_integer(v_out(i,j));
                report "v_out(" & integer'image(i) & "," & integer'image(j) & ") = " & integer'image(val);
            end loop;
        end loop;

        -- 3. Giá tr? nh?
        for i in 0 to K-1 loop
            for j in 0 to N-1 loop
                v_in(i,j) <= to_signed((i*10+j)*12345, COEFF_WIDTH);
            end loop;
        end loop;
        wait for 2000 ns;

        -- In k?t qu?
        for i in 0 to K-1 loop
            for j in 0 to N-1 loop
                val := to_integer(v_out(i,j));
                report "v_out(" & integer'image(i) & "," & integer'image(j) & ") = " & integer'image(val);
            end loop;
        end loop;

        -- K?t thúc mô ph?ng
        wait;
    end process;

end architecture;
