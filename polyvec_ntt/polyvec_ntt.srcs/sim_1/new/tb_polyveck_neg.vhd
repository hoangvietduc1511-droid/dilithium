library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_polyveck_neg is
end tb_polyveck_neg;

architecture sim of tb_polyveck_neg is
    -------------------------------------------------------------------------
    -- Test parameters
    -------------------------------------------------------------------------
    constant K : natural := 2;
    constant N : natural := 8;
    constant Q : integer := 8380417;

    -------------------------------------------------------------------------
    -- DUT signals
    -------------------------------------------------------------------------
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal start : std_logic := '0';
    signal done  : std_logic;

    signal v_in  : polyvec_t(0 to K-1, 0 to N-1);
    signal v_out : polyvec_t(0 to K-1, 0 to N-1);

begin
    -------------------------------------------------------------------------
    -- Clock generation
    -------------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    -------------------------------------------------------------------------
    -- DUT instantiation
    -------------------------------------------------------------------------
    uut : entity work.polyveck_neg
        generic map (
            K => K,
            N => N,
            Q => Q
        )
        port map (
            clk   => clk,
            rst   => rst,
            start => start,
            done  => done,
            v_in  => v_in,
            v_out => v_out
        );

    -------------------------------------------------------------------------
    -- Stimulus
    -------------------------------------------------------------------------
    stim_proc : process
        variable j : integer;
    begin
        ---------------------------------------------------------------------
        -- Reset
        ---------------------------------------------------------------------
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        ---------------------------------------------------------------------
        -- Kh?i t?o d? li?u ??u vào v_in
        ---------------------------------------------------------------------
        for i in 0 to K-1 loop
            for j in 0 to N-1 loop
                v_in(i, j) <= to_signed((i+1)*100 + j, COEFF_WIDTH);
            end loop;
        end loop;

        ---------------------------------------------------------------------
        -- B?t ??u th?c thi
        ---------------------------------------------------------------------
        wait for 20 ns;
        start <= '1';
        wait for 10 ns;
        start <= '0';

        ---------------------------------------------------------------------
        -- Ch? hoàn t?t
        ---------------------------------------------------------------------
        wait until done = '1';
        wait for 10 ns;

        ---------------------------------------------------------------------
        -- Hi?n th? k?t qu?
        ---------------------------------------------------------------------
        report "==== polyveck_neg output ====";
        for i in 0 to K-1 loop
            report "Vector " & integer'image(i) & ":";
            for j in 0 to N-1 loop
                report "v_in(" & integer'image(i) & "," & integer'image(j) & ") = " &
                       integer'image(to_integer(v_in(i,j))) &
                       "   --> v_out(" & integer'image(i) & "," & integer'image(j) & ") = " &
                       integer'image(to_integer(v_out(i,j)));
            end loop;
        end loop;

        ---------------------------------------------------------------------
        -- K?t thúc mô ph?ng
        ---------------------------------------------------------------------
        wait for 50 ns;
        report "Simulation finished successfully." severity note;
        wait;
    end process;

end sim;
