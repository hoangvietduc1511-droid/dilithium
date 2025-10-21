library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity polyvecl_pointwise_acc_invmontgomery is
  generic (
    N : natural := 8;  -- s? h? s? trong ?a th?c
    L : natural := 2   -- s? ?a th?c trong vector
  );
  port (
    clk   : in  std_logic;
    start : in  std_logic;
    u_in  : in  polyvec_t(0 to L-1, 0 to N-1);
    v_in  : in  polyvec_t(0 to L-1, 0 to N-1);
    done  : out std_logic;
    w_out : out poly_t(0 to N-1)
  );
end entity;

architecture rtl of polyvecl_pointwise_acc_invmontgomery is
  -- component declaration
  component poly_pointwise_invmontgomery
    generic (
      N : natural := 8
    );
    port (
      clk   : in  std_logic;
      start : in  std_logic;
      a_in  : in  poly_t(0 to N-1);
      b_in  : in  poly_t(0 to N-1);
      done  : out std_logic;
      c_out : out poly_t(0 to N-1)
    );
  end component;

  signal temp_res : poly_t(0 to N-1);
  signal acc      : poly_t(0 to N-1);
  signal idx      : integer range 0 to L := 0;
  signal busy     : std_logic := '0';
  signal done_p   : std_logic := '0';

begin
  -- FSM controller
  process(clk)
  begin
    if rising_edge(clk) then
      if start = '1' and busy = '0' then
        acc  <= (others => (others => '0'));
        idx  <= 0;
        busy <= '1';
        done_p <= '0';
      elsif busy = '1' then
        if done_p = '1' then
          -- accumulate k?t qu?
          for j in 0 to N-1 loop
            acc(j) <= acc(j) + temp_res(j);
          end loop;
          if idx = L-1 then
            busy   <= '0';
            w_out  <= acc;
            done_p <= '0';
            done   <= '1';
          else
            idx    <= idx + 1;
            done_p <= '0';
          end if;
        end if;
      else
        done <= '0';
      end if;
    end if;
  end process;

  -- g?i poly_pointwise_invmontgomery
  inst_ppi: poly_pointwise_invmontgomery
    generic map (N => N)
    port map (
      clk   => clk,
      start => busy,        -- ch?y khi ?ang b?n
      a_in  => u_in(idx, 0 to N-1),
      b_in  => v_in(idx, 0 to N-1),
      done  => done_p,
      c_out => temp_res
    );

end architecture;
