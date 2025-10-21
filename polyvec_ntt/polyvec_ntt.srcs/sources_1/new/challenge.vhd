-- challenge.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity challenge is
    port(
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
        mu    : in  std_logic_vector(511 downto 0);  -- 64 bytes input
        c_out : out std_logic_vector(255 downto 0);  -- 32 bytes output
        done  : out std_logic
    );
end entity;

architecture rtl of challenge is

    -- internal signals to connect to wrapper
    signal done_int : std_logic;
    signal c_int    : std_logic_vector(255 downto 0);

begin

    -- instantiate wrapper
    U_WRAPPER: entity work.shake256_wrapper
        port map(
            clk    => clk,
            rst    => rst,
            start  => start,
            mu     => mu,
            c_out  => c_int,
            done   => done_int
        );

    -- map outputs
    c_out <= c_int;
    done  <= done_int;

end architecture;
