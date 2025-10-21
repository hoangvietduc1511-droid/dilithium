library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_make_hint is
end entity;

architecture sim of tb_make_hint is

    -- Component under test
    component make_hint
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            a_in  : in  unsigned(31 downto 0);
            b_in  : in  unsigned(31 downto 0);
            hint  : out std_logic
        );
    end component;

    -- Signals
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal a_in  : unsigned(31 downto 0) := (others => '0');
    signal b_in  : unsigned(31 downto 0) := (others => '0');
    signal hint  : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin
    --------------------------------------------------------------------------
    -- Clock generation
    --------------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    --------------------------------------------------------------------------
    -- Instantiate DUT
    --------------------------------------------------------------------------
    uut: make_hint
        port map (
            clk  => clk,
            rst  => rst,
            a_in => a_in,
            b_in => b_in,
            hint => hint
        );

    --------------------------------------------------------------------------
    -- Stimulus
    --------------------------------------------------------------------------
    stim_proc: process
    begin
        ----------------------------------------------------------------------
        -- Reset phase
        ----------------------------------------------------------------------
        rst <= '1';
        wait for 30 ns;
        rst <= '0';

        ----------------------------------------------------------------------
        -- Test cases
        ----------------------------------------------------------------------
        -- Case 1
        a_in <= to_unsigned(100000, 32);
        b_in <= to_unsigned(200000, 32);
        wait for 40 ns;
        report "Case 1: a=100000, b=200000 => hint=" & std_logic'image(hint);

        -- Case 2
        a_in <= to_unsigned(500000, 32);
        b_in <= to_unsigned(1000000, 32);
        wait for 40 ns;
        report "Case 2: a=500000, b=1000000 => hint=" & std_logic'image(hint);

        -- Case 3
        a_in <= to_unsigned(4000000, 32);
        b_in <= to_unsigned(4300000, 32);
        wait for 40 ns;
        report "Case 3: a=4000000, b=4300000 => hint=" & std_logic'image(hint);

        -- Case 4 (biên g?n Q)
        a_in <= to_unsigned(8380000, 32);
        b_in <= to_unsigned(600, 32);
        wait for 40 ns;
        report "Case 4: a=8380000, b=600 => hint=" & std_logic'image(hint);

        -- Case 5 (ng?u nhiên)
        a_in <= to_unsigned(1234567, 32);
        b_in <= to_unsigned(765432, 32);
        wait for 40 ns;
        report "Case 5: a=1234567, b=765432 => hint=" & std_logic'image(hint);

        wait for 100 ns;
        report "Simulation finished.";
        wait;
    end process;

end architecture sim;
