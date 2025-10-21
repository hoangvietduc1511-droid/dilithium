
---- tb_decompose_wave.vhd
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity tb_decompose_wave is
--end tb_decompose_wave;

--architecture Behavioral of tb_decompose_wave is
--    -- Clock and reset
--    signal clk    : std_logic := '0';
--    signal rst    : std_logic := '1';

--    -- DUT ports
--    signal a_in   : unsigned(31 downto 0);
--    signal a0_out : unsigned(31 downto 0);
--    signal a1_out : unsigned(3 downto 0);

--    constant clk_period : time := 10 ns;

--    -- Test vectors
--    type test_array is array (0 to 3) of unsigned(31 downto 0);
--    constant test_values : test_array := (
--        to_unsigned(0,32),
--        to_unsigned(8380416,32), -- Q-1
--        to_unsigned(1234567,32),
--        to_unsigned(4000000,32)
--    );
--begin
--    -- DUT instance
--    DUT: entity work.decompose
--        port map(
--            clk => clk,
--            rst => rst,
--            a_in => a_in,
--            a0_out => a0_out,
--            a1_out => a1_out
--        );

--    -- Clock generation
--    clk_process : process
--    begin
--        while true loop
--            clk <= '0';
--            wait for clk_period/2;
--            clk <= '1';
--            wait for clk_period/2;
--        end loop;
--    end process;

--    -- Stimulus process
--    stim_proc: process
--    begin
--        -- Reset
--        rst <= '1';
--        wait for clk_period*2;
--        rst <= '0';
--        wait for clk_period*2;

--        -- Apply each test vector, gi? ?? th?i gian ?? DUT tính toán
--        a_in <= test_values(0);  -- a = 0
--        wait for clk_period*4;

--        a_in <= test_values(1);  -- a = Q-1
--        wait for clk_period*4;

--        a_in <= test_values(2);  -- a = 1234567
--        wait for clk_period*4;

--        a_in <= test_values(3);  -- a = 4000000
--        wait for clk_period*4;

--        -- K?t thúc simulation
--        wait;
--    end process;
--end Behavioral;

-- tb_decompose_wave_test.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_decompose_wave_test is
end tb_decompose_wave_test;

architecture Behavioral of tb_decompose_wave_test is
    -- Clock and reset
    signal clk    : std_logic := '0';
    signal rst    : std_logic := '1';

    -- DUT ports
    signal a_in   : unsigned(31 downto 0);
    signal a0_out : unsigned(31 downto 0);
    signal a1_out : unsigned(3 downto 0);

    constant clk_period : time := 10 ns;

    -- Test vectors
    type test_array is array (0 to 4) of unsigned(31 downto 0);
    constant test_values : test_array := (
        to_unsigned(0,32),         -- a = 0
        to_unsigned(8380416,32),   -- a = Q-1
        to_unsigned(1234567,32),   -- a = 1234567
        to_unsigned(4000000,32),   -- a = 4000000
        to_unsigned(16#007FE000#,32) -- a = 0x007FE000
    );
begin
    -- Instantiate DUT
    DUT: entity work.decompose
        port map(
            clk => clk,
            rst => rst,
            a_in => a_in,
            a0_out => a0_out,
            a1_out => a1_out
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus process: apply test vectors sequentially
    stim_proc: process
    begin
        -- Reset
        rst <= '1';
        wait for clk_period*2;
        rst <= '0';
        wait for clk_period*2;

        -- Apply test vectors with enough delay for waveform observation
        a_in <= test_values(0); wait for clk_period*4;
        a_in <= test_values(1); wait for clk_period*4;
        a_in <= test_values(2); wait for clk_period*4;
        a_in <= test_values(3); wait for clk_period*4;
        a_in <= test_values(4); wait for clk_period*4;

        wait; -- stop simulation
    end process;
end Behavioral;
