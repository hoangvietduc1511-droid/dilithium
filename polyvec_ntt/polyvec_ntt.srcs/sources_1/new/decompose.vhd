library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decompose is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        a_in     : in  unsigned(31 downto 0);
        a0_out   : out unsigned(31 downto 0);
        a1_out   : out unsigned(3 downto 0)
    );
end entity;

architecture Behavioral of decompose is
    -- Ví d? Q = 8380417 (Dilithium), ALPHA = (Q-1)/16
    constant Q     : signed(31 downto 0) := to_signed(8380417,32);
    constant ALPHA : signed(31 downto 0) := to_signed((8380417-1)/16,32);

    signal t, a, u, tmp_a0 : signed(31 downto 0);
    signal tmp_a1          : unsigned(3 downto 0);
begin
   process(clk)
    variable a_var, t_var, u_var, tmp_a0_var : signed(31 downto 0);
    variable tmp_a1_var : unsigned(3 downto 0);
begin
    if rising_edge(clk) then
        if rst='1' then
            a0_out <= (others=>'0');
            a1_out <= (others=>'0');
        else
            -- Step 1: Centralized remainder mod ALPHA
            t_var := signed(a_in and x"7FFFF");
            t_var := t_var + shift_left(signed(a_in(31 downto 19)),9);
            t_var := t_var - (ALPHA/2 + 1);
            if t_var(31)='1' then
                t_var := t_var + ALPHA;
            end if;
            t_var := t_var - (ALPHA/2 - 1);
            a_var := signed(a_in) - t_var;

            -- Step 2: Divide by ALPHA
            u_var := a_var - 1;
            u_var := shift_right(u_var,31);  -- arithmetic shift
            a_var := shift_right(a_var,19) + 1;

            -- a -= (u & 1)  --> l?y bit 0 c?a u_var
            if u_var(0)='1' then
                a_var := a_var - 1;
            end if;

            -- Step 3: Border case
            tmp_a0_var := Q + t_var - shift_right(a_var,4);
            tmp_a1_var := unsigned(a_var(3 downto 0));

            -- Assign output signals
            a0_out <= unsigned(tmp_a0_var);
            a1_out <= tmp_a1_var;
        end if;
    end if;
end process;
end architecture;
