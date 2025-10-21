library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_decompose is
end tb_decompose;

architecture Behavioral of tb_decompose is
    signal clk    : std_logic := '0';
    signal rst    : std_logic := '1';
    signal a_in   : unsigned(31 downto 0);
    signal a0_out : unsigned(31 downto 0);
    signal a1_out : unsigned(3 downto 0);

    constant clk_period : time := 10 ns;
begin
    -- Instantiate DUT
    DUT: entity work.decompose
        port map(
            clk      => clk,
            rst      => rst,
            a_in     => a_in,
            a0_out   => a0_out,
            a1_out   => a1_out
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        wait for 20 ns;
        rst <= '0';

        a_in <= to_unsigned(0,32);
        wait for clk_period*2;

        a_in <= to_unsigned(8380416,32); -- Q-1
        wait for clk_period*2;

        a_in <= to_unsigned(1234567,32);
        wait for clk_period*2;

        a_in <= to_unsigned(4000000,32);
        wait for clk_period*2;

        wait; -- stop simulation
    end process;
end Behavioral;
