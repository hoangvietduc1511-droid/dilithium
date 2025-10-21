library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_polyvecl_freeze is
end entity;

architecture sim of tb_polyvecl_freeze is

    -- Tham s? gi?ng trong Dilithium
    constant L : natural := 4;
    constant N : natural := 256;

    -- Tín hi?u test
    signal clk    : std_logic := '0';
    signal l_in   : polyvec_t(0 to L-1, 0 to N-1);
    signal l_out  : polyvec_t(0 to L-1, 0 to N-1);

begin

    --------------------------------------------------------------------
    -- T?o clock 10ns (100 MHz)
    --------------------------------------------------------------------
    clk <= not clk after 5 ns;

    --------------------------------------------------------------------
    -- K?t n?i DUT
    --------------------------------------------------------------------
    DUT: entity work.polyvecl_freeze
        generic map(
            L => L,
            N => N
        )
        port map(
            clk   => clk,
            l_in  => l_in,
            l_out => l_out
        );

    --------------------------------------------------------------------
    -- Test process
    --------------------------------------------------------------------
    process
        variable val : integer;
    begin
        ----------------------------------------------------------------
        -- 1?? Tr??ng h?p 1: giá tr? l?n (g?n Q)
        ----------------------------------------------------------------
        report "==== Test 1: Large positive coefficients ====";
        for i in 0 to L-1 loop
            for j in 0 to N-1 loop
                l_in(i,j) <= to_signed(8000000 + i*1000 + j, COEFF_WIDTH);
            end loop;
        end loop;
        wait for 2000 ns;

        for i in 0 to L-1 loop
            for j in 0 to 7 loop  -- ch? in vài giá tr? ??u
                val := to_integer(l_out(i,j));
                report "l_out(" & integer'image(i) & "," & integer'image(j) & ") = " & integer'image(val);
            end loop;
        end loop;

        ----------------------------------------------------------------
        -- 2?? Tr??ng h?p 2: giá tr? âm (negative)
        ----------------------------------------------------------------
        report "==== Test 2: Negative coefficients ====";
        for i in 0 to L-1 loop
            for j in 0 to N-1 loop
                l_in(i,j) <= to_signed(-9000000 + i*50 - j*10, COEFF_WIDTH);
            end loop;
        end loop;
        wait for 2000 ns;

        for i in 0 to L-1 loop
            for j in 0 to 7 loop
                val := to_integer(l_out(i,j));
                report "l_out(" & integer'image(i) & "," & integer'image(j) & ") = " & integer'image(val);
            end loop;
        end loop;

        ----------------------------------------------------------------
        -- 3?? Tr??ng h?p 3: giá tr? nh? (trong kho?ng h?p l?)
        ----------------------------------------------------------------
        report "==== Test 3: Small coefficients ====";
        for i in 0 to L-1 loop
            for j in 0 to N-1 loop
                l_in(i,j) <= to_signed(i*100 + j*5, COEFF_WIDTH);
            end loop;
        end loop;
        wait for 2000 ns;

        for i in 0 to L-1 loop
            for j in 0 to 7 loop
                val := to_integer(l_out(i,j));
                report "l_out(" & integer'image(i) & "," & integer'image(j) & ") = " & integer'image(val);
            end loop;
        end loop;

        ----------------------------------------------------------------
        -- K?t thúc mô ph?ng
        ----------------------------------------------------------------
        report "==== Simulation finished ====";
        wait;
    end process;

end architecture;
