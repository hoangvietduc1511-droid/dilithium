library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity make_hint is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        a_in  : in  unsigned(31 downto 0);
        b_in  : in  unsigned(31 downto 0);
        hint  : out std_logic
    );
end entity make_hint;

architecture Behavioral of make_hint is
    --------------------------------------------------------------------------
    -- Constants
    --------------------------------------------------------------------------
    constant Q : signed(31 downto 0) := to_signed(8380417, 32);

    --------------------------------------------------------------------------
    -- Internal signals
    --------------------------------------------------------------------------
    signal a_freeze   : signed(31 downto 0);
    signal sum_ab     : signed(31 downto 0);

    signal a0_a, a0_b : unsigned(31 downto 0);
    signal a1_a, a1_b : unsigned(3 downto 0);

begin

    --------------------------------------------------------------------------
    -- Sum and freeze(a + b)
    --------------------------------------------------------------------------
    process(a_in, b_in)
        variable tmp : signed(31 downto 0);
    begin
        tmp := signed(a_in) + signed(b_in);
        -- Freeze: ??a v? [0, Q)
        while tmp >= Q loop
            tmp := tmp - Q;
        end loop;
        while tmp < to_signed(0, 32) loop
            tmp := tmp + Q;
        end loop;
        sum_ab <= tmp;
    end process;

    --------------------------------------------------------------------------
    -- Instantiate decompose for "a"
    --------------------------------------------------------------------------
    decomp_a: entity work.decompose
        port map(
            clk    => clk,
            rst    => rst,
            a_in   => a_in,
            a0_out => a0_a,
            a1_out => a1_a
        );

    --------------------------------------------------------------------------
    -- Instantiate decompose for "freeze(a+b)"
    --------------------------------------------------------------------------
    decomp_b: entity work.decompose
        port map(
            clk    => clk,
            rst    => rst,
            a_in   => unsigned(sum_ab),
            a0_out => a0_b,
            a1_out => a1_b
        );

    --------------------------------------------------------------------------
    -- Compare the high bits => hint
    --------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                hint <= '0';
            else
                if (a1_a /= a1_b) then
                    hint <= '1';
                else
                    hint <= '0';
                end if;
            end if;
        end if;
    end process;

end architecture Behavioral;
