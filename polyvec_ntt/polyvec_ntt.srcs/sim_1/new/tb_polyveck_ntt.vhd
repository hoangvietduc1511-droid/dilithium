library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_polyveck_ntt is
end entity;

architecture sim of tb_polyveck_ntt is
  constant K : natural := 2;
  constant N : natural := 8;

  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';
  signal start : std_logic := '0';
  signal done  : std_logic;

  signal v_in  : polyvec_t(0 to K-1, 0 to N-1);
  signal v_out : polyvec_t(0 to K-1, 0 to N-1);

begin
  -- Clock 10ns period
  clk <= not clk after 5 ns;

  -- DUT
  uut: entity work.polyveck_ntt
    generic map (
      K => K,
      N => N
    )
    port map (
      clk   => clk,
      reset => reset,
      start => start,
      v_in  => v_in,
      done  => done,
      v_out => v_out
    );

  -- Stimulus
  process
  begin
    -- Reset
    reset <= '1';
    wait for 20 ns;
    reset <= '0';

    -- Init input vector
    for i in 0 to K-1 loop
      for j in 0 to N-1 loop
        v_in(i,j) <= to_signed(i*10 + j, 32);
      end loop;
    end loop;

    -- Start processing
    wait for 20 ns;
    start <= '1';
    wait for 10 ns;
    start <= '0';

    -- Wait for done
    wait until done = '1';
    wait for 20 ns;

    -- Print results
    report "Simulation finished. Check waveform for v_out values.";

    wait;
  end process;
end architecture;
