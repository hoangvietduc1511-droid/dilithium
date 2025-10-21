---- tb_challenge.vhd
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--use STD.TEXTIO.ALL;
--use IEEE.STD_LOGIC_TEXTIO.ALL;

--entity tb_challenge is
--end entity;

--architecture sim of tb_challenge is

--    constant clk_period : time := 10 ns;

--    signal clk    : std_logic := '0';
--    signal rst    : std_logic := '0';
--    signal start  : std_logic := '0';
--    signal mu     : std_logic_vector(511 downto 0) := (others => '0');
--    signal c_out  : std_logic_vector(255 downto 0);
--    signal done   : std_logic;

--    -- Helper: convert std_logic_vector -> bit_vector
--    function slv_to_bv(slv: std_logic_vector) return bit_vector is
--        variable bv : bit_vector(slv'range);
--    begin
--        for i in slv'range loop
--            if slv(i) = '1' then
--                bv(i) := '1';
--            else
--                bv(i) := '0';
--            end if;
--        end loop;
--        return bv;
--    end function;

--begin

--    -- Instantiate challenge
--    U_CHALLENGE: entity work.challenge
--        port map(
--            clk   => clk,
--            rst   => rst,
--            start => start,
--            mu    => mu,
--            c_out => c_out,
--            done  => done
--        );

--    -- Clock generation
--    clk_proc : process
--    begin
--        while true loop
--            clk <= '0'; wait for clk_period/2;
--            clk <= '1'; wait for clk_period/2;
--        end loop;
--    end process;

--    -- Stimulus
--    stim_proc : process
--        variable L : line;
--    begin
--        -- Reset
--        rst <= '1';
--        wait for 2*clk_period;
--        rst <= '0';
--        wait for clk_period;

--        -- Example mu input (0..63)
--        for i in 0 to 63 loop
--            mu((i+1)*8-1 downto i*8) <= std_logic_vector(to_unsigned(i,8));
--        end loop;

--        -- Start
--        start <= '1';
--        wait for clk_period;
--        start <= '0';

--        -- Wait for done
--        wait until done = '1';

--        -- Print c_out
--        report "Challenge output c_out:";
--        for i in 0 to 31 loop
--            write(L, string'("Byte(" & integer'image(i) & ") = " &
--                             to_hstring(slv_to_bv(c_out((i+1)*8-1 downto i*8)))));
--            writeline(output, L);
--        end loop;

--        wait;
--    end process;

--end architecture;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_challenge_final is
end tb_challenge_final;

architecture sim of tb_challenge_final is

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

    -- DUT signals
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal start : std_logic := '0';
    signal mu    : std_logic_vector(511 downto 0) := (others => '0');
    signal c_out : std_logic_vector(255 downto 0);
    signal done  : std_logic := '0';

begin

    --------------------------------------------------------------------
    -- Instantiate DUT
    --------------------------------------------------------------------
    UUT: entity work.challenge
        port map(
            clk   => clk,
            rst   => rst,
            start => start,
            mu    => mu,
            c_out => c_out,
            done  => done
        );

    --------------------------------------------------------------------
    -- Clock generation
    --------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process clk_process;

    --------------------------------------------------------------------
    -- Stimulus process
    --------------------------------------------------------------------
    stim_proc : process
    begin
        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 20 ns;

        ----------------------------------------------------------------
        -- Apply mu (64 bytes, 512 bits)
        -- Ví d? gán m?u t??ng t? Dilithium: mu = 00 01 02 03 ... 3F
        ----------------------------------------------------------------
        for i in 0 to 63 loop
            mu((i+1)*8-1 downto i*8) <= std_logic_vector(to_unsigned(i, 8));
        end loop;

        ----------------------------------------------------------------
        -- Start pulse (1 chu k? clock)
        ----------------------------------------------------------------
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';

        ----------------------------------------------------------------
        -- Wait for done = '1'
        ----------------------------------------------------------------
        wait until rising_edge(clk);
        wait until done = '1';

        ----------------------------------------------------------------
        -- Print result
        ----------------------------------------------------------------
        report "==== Challenge output (c_out) ====" severity note;
        for i in 31 downto 0 loop
            report "Byte(" & integer'image(i) & ") = " &
                to_hstring(c_out((i*8+7) downto (i*8))) severity note;
        end loop;
        report "==== Simulation completed ====" severity note;

        wait;
    end process;

end sim;





