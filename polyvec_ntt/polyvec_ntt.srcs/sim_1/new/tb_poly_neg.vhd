library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_poly_neg is
end tb_poly_neg;

architecture sim of tb_poly_neg is

    -- Thông s?
    constant N : natural := 8;           -- Gi?m xu?ng cho mô ph?ng d? xem
    constant Q : integer := 8380417;

    -- Tín hi?u mô ph?ng
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal start : std_logic := '0';
    signal done  : std_logic;
    signal a_in  : poly_t(0 to N-1);
    signal a_out : poly_t(0 to N-1);

begin
    --------------------------------------------------------------------------
    -- Clock process: 10 ns chu k?
    --------------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    --------------------------------------------------------------------------
    -- Instance c?a poly_neg
    --------------------------------------------------------------------------
    uut: entity work.poly_neg
        generic map (
            N => N,
            Q => Q
        )
        port map (
            clk   => clk,
            rst   => rst,
            start => start,
            a_in  => a_in,
            done  => done,
            a_out => a_out
        );

    --------------------------------------------------------------------------
    -- Stimulus process
    --------------------------------------------------------------------------
    stim_proc : process
    begin
        ----------------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------------
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        ----------------------------------------------------------------------
        -- Gán d? li?u ??u vào
        ----------------------------------------------------------------------
        a_in(0) <= to_signed(100, COEFF_WIDTH);
        a_in(1) <= to_signed(5000, COEFF_WIDTH);
        a_in(2) <= to_signed(70000, COEFF_WIDTH);
        a_in(3) <= to_signed(100000, COEFF_WIDTH);
        a_in(4) <= to_signed(200000, COEFF_WIDTH);
        a_in(5) <= to_signed(300000, COEFF_WIDTH);
        a_in(6) <= to_signed(8380000, COEFF_WIDTH);
        a_in(7) <= to_signed(2, COEFF_WIDTH);

        ----------------------------------------------------------------------
        -- B?t ??u x? lý
        ----------------------------------------------------------------------
        start <= '1';
        wait for 10 ns;
        start <= '0';

        ----------------------------------------------------------------------
        -- Ch? hoàn t?t
        ----------------------------------------------------------------------
        wait until done = '1';
        wait for 10 ns;

        ----------------------------------------------------------------------
        -- In k?t qu? ra console
        ----------------------------------------------------------------------
        report "====== K?T QU? poly_neg ======";
        for i in 0 to N-1 loop
            report "a_in(" & integer'image(i) & ") = " &
                   integer'image(to_integer(a_in(i))) &
                   "  -->  a_out(" & integer'image(i) & ") = " &
                   integer'image(to_integer(a_out(i)));
        end loop;

        report "==== Mô ph?ng hoàn t?t ====" severity note;

        wait;
    end process;

end sim;
