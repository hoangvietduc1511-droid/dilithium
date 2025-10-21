library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rej_gamma1m1 is
    generic (
        LEN    : integer := 256;    -- s? l??ng coefficients
        GAMMA1 : integer := 8380417;
        BUFLEN : integer := 512     -- s? byte buffer
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        start   : in  std_logic;
        key     : in  std_logic_vector(639 downto 0);  -- 80 bytes
        nonce   : in  std_logic_vector(15 downto 0);   -- 2 bytes
        buf_in  : in  std_logic_vector(BUFLEN*8-1 downto 0); -- d? li?u t? SHAKE256
        done    : out std_logic;
        a_flat  : out std_logic_vector(LEN*32-1 downto 0)   -- k?t qu? coeffs
    );
end entity;

architecture rtl of rej_gamma1m1 is

    -- m?ng h? s?
    type coeff_array_t is array (0 to LEN-1) of signed(31 downto 0);
    signal coeffs : coeff_array_t := (others => (others => '0'));

    signal idx      : integer range 0 to LEN := 0;
    signal working  : std_logic := '0';

begin

    -- FSM ??n gi?n ?? ??c d? li?u t? buf_in và ghi vào coeffs
    process(clk, rst)
    begin
        if rst = '1' then
            idx      <= 0;
            working  <= '0';
            done     <= '0';
            coeffs   <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if start = '1' and working = '0' then
                working <= '1';
                idx     <= 0;
                done    <= '0';
            elsif working = '1' then
                if idx < LEN then
                    -- ví d?: l?y m?i 4 byte t? buf_in thành 1 coefficient
                    coeffs(idx) <= signed(buf_in((idx+1)*32-1 downto idx*32));
                    idx <= idx + 1;
                else
                    working <= '0';
                    done    <= '1';
                end if;
            else
                done <= '0';
            end if;
        end if;
    end process;

    -- pack coeffs thành vector ph?ng
    pack_proc: process(coeffs)
    begin
        for i in 0 to LEN-1 loop
            a_flat((i+1)*32-1 downto i*32) <= std_logic_vector(coeffs(i));
        end loop;
    end process;

end architecture;
