-- tb_polyveck_decompose.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.polyveck_pkg.all;

entity tb_polyveck_decompose is
end tb_polyveck_decompose;

architecture sim of tb_polyveck_decompose is

    signal clk    : std_logic := '0';
    signal rst    : std_logic := '1';

    -- s? d?ng lo?i coeff_array32/coeff_array4 t? polyveck_pkg
    signal v_in   : coeff_array32 := (others => (others => (others => '0')));
    signal v0_out : coeff_array32;
    signal v1_out : coeff_array4;

    constant clk_period : time := 10 ns;

    -- Test vectors (aggregate 2D, kích th??c theo K,N trong package)
    constant test_values : coeff_array32 := (
        0 => ( 0 => to_unsigned(0,32),
               1 => to_unsigned(8380416,32),       -- Q-1
               2 => to_unsigned(1234567,32),
               3 => to_unsigned(16#007FE000#,32) ),
        1 => ( 0 => to_unsigned(4000000,32),
               1 => to_unsigned(1,32),
               2 => to_unsigned(500000,32),
               3 => to_unsigned(7000000,32) )
    );

    -- component declaration (matching entity)
    component polyveck_decompose
        port(
            clk    : in  std_logic;
            rst    : in  std_logic;
            v_in   : in  coeff_array32;
            v0_out : out coeff_array32;
            v1_out : out coeff_array4
        );
    end component;

begin

    -- clock
    clk_proc : process
    begin
        while true loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
    end process;

    -- instantiate DUT
    DUT_inst : polyveck_decompose
        port map (
            clk    => clk,
            rst    => rst,
            v_in   => v_in,
            v0_out => v0_out,
            v1_out => v1_out
        );

    -- stimulus
    stim : process
    begin
        -- reset
        rst <= '1';
        wait for 2 * clk_period;
        rst <= '0';
        wait for clk_period;

        -- load toàn b? test_values vào v_in
        v_in <= test_values;
        -- ??i vài chu k? ?? DUT tính xong (KxN loop trong DUT ch?y trên m?i c?nh lên c?a clk)
        wait for 10 * clk_period;

        -- in ra k?t qu?: l?u ý chuy?n v0_out sang signed tr??c to_integer ?? hi?n th? -1 ?úng
        for i in 0 to K-1 loop
            for j in 0 to N-1 loop
                report "v_in(" & integer'image(i) & "," & integer'image(j) & ") = " &
                       integer'image(to_integer(v_in(i,j))) &
                       "  => v0_out = " & integer'image(to_integer(signed(v0_out(i,j)))) &
                       ", v1_out = " & integer'image(to_integer(resize(v1_out(i,j),32)));
            end loop;
        end loop;

        wait; -- d?ng mô ph?ng
    end process;

end architecture;
