library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity tb_polyveck_make_hint is
end entity;

architecture sim of tb_polyveck_make_hint is
    constant K : natural := 2;
    constant N : natural := 8;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal start : std_logic := '0';
    signal done  : std_logic;

    signal u_vec : unsigned(32*K*N - 1 downto 0) := (others => '0');
    signal v_vec : unsigned(32*K*N - 1 downto 0) := (others => '0');
    signal h_vec : std_logic_vector(K*N - 1 downto 0);
    signal s_out : unsigned(15 downto 0);

begin

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- DUT
    uut: entity work.polyveck_make_hint
        generic map(
            K => K,
            N => N
        )
        port map(
            clk   => clk,
            rst   => rst,
            start => start,
            u_vec => u_vec,
            v_vec => v_vec,
            done  => done,
            h_vec => h_vec,
            s_out => s_out
        );

    -- Test process
    stim_proc: process
        variable L : line;
    begin
        -- Reset
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- Init input vectors
        for i in 0 to K*N-1 loop
            u_vec(32*(i+1)-1 downto 32*i) <= to_unsigned(i*10, 32);
            v_vec(32*(i+1)-1 downto 32*i) <= to_unsigned(i*10 + 5, 32);
        end loop;

        -- Start
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- Wait until done
        wait until done = '1';
        wait for 10 ns;

        -- Print results
        write(L, string'("h_vec = "));
        for i in 0 to K*N-1 loop
            -- CH? S?A QUAN TR?NG
            write(L, std_logic'image(h_vec(i)));
        end loop;
        writeline(output, L);

        write(L, string'("s_out = "));
        write(L, integer(to_integer(s_out)));
        writeline(output, L);

        wait;
    end process;

end architecture;
