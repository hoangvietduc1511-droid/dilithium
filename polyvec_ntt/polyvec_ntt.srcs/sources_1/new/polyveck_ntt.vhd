library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity polyveck_ntt is
  generic (
    K : natural := 4;
    N : natural := 256
  );
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    start : in  std_logic;
    v_in  : in  polyvec_t(0 to K-1, 0 to N-1);
    done  : out std_logic;
    v_out : out polyvec_t(0 to K-1, 0 to N-1)
  );
end entity;

architecture rtl of polyveck_ntt is
  component poly_ntt
    generic (N : natural := 256);
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      start : in  std_logic;
      a_in  : in  poly_t(0 to N-1);
      done  : out std_logic;
      a_out : out poly_t(0 to N-1)
    );
  end component;

  signal poly_in   : poly_t(0 to N-1);
  signal poly_out  : poly_t(0 to N-1);
  signal poly_done : std_logic;
  signal idx       : natural range 0 to K-1 := 0;
  signal state     : integer range 0 to 2 := 0;
  signal core_start: std_logic := '0';
begin
  core_start <= '1' when state = 1 else '0';

  u_poly_ntt: poly_ntt
    generic map (N => N)
    port map (
      clk   => clk,
      reset => reset,
      start => core_start,
      a_in  => poly_in,
      done  => poly_done,
      a_out => poly_out
    );

  process(clk, reset)
  begin
    if reset = '1' then
      idx    <= 0;
      state  <= 0;
      done   <= '0';
      v_out  <= (others => (others => (others => '0')));
      poly_in <= (others => (others => '0'));
    elsif rising_edge(clk) then
      case state is
        when 0 =>
          done <= '0';
          if start = '1' then
            idx <= 0;
            for i in 0 to N-1 loop
              poly_in(i) <= v_in(0, i);
            end loop;
            state <= 1;
          end if;

        when 1 =>
          if poly_done = '1' then
            for i in 0 to N-1 loop
              v_out(idx, i) <= poly_out(i);
            end loop;
            if idx = K-1 then
              done <= '1';
              state <= 0;
            else
              idx <= idx + 1;
              for i in 0 to N-1 loop
                poly_in(i) <= v_in(idx+1, i);
              end loop;
              state <= 1;
            end if;
          end if;

        when others =>
          state <= 0;
      end case;
    end if;
  end process;
end architecture;
