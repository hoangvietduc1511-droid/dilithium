library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity poly_neg is
    generic (
        N : natural := 256;         -- S? h? s? trong ?a th?c
        Q : integer := 8380417      -- Modulus Q (theo Dilithium)
    );
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
        a_in  : in  poly_t(0 to N-1);   -- ?a th?c ??u vào
        done  : out std_logic;
        a_out : out poly_t(0 to N-1)    -- K?t qu? ??o d?u
    );
end entity poly_neg;

architecture rtl of poly_neg is
    signal a_reg : poly_t(0 to N-1);
    signal i     : integer range 0 to N := 0;
    signal busy  : std_logic := '0';
begin

    process(clk, rst)
    begin
        if rst = '1' then
            i     <= 0;
            busy  <= '0';
            done  <= '0';
            a_reg <= (others => (others => '0'));

        elsif rising_edge(clk) then
            if start = '1' and busy = '0' then
                i    <= 0;
                busy <= '1';
                done <= '0';

            elsif busy = '1' then
                a_reg(i) <= to_signed(2*Q, COEFF_WIDTH) - a_in(i);

                if i = N-1 then
                    busy <= '0';
                    done <= '1';
                else
                    i <= i + 1;
                end if;
            else
                done <= '0';
            end if;
        end if;
    end process;

    a_out <= a_reg;

end architecture rtl;
