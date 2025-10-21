library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.poly_pkg.all;

entity polyvecl_chknorm is
  generic (
    L : natural := 4;        -- s? poly trong vector
    N : natural := 256       -- s? coefficient trong m?i poly
  );
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    start     : in  std_logic;
    v         : in  polyvec_t(0 to L-1, 0 to N-1);  -- vector poly
    B         : in  unsigned(COEFF_WIDTH-1 downto 0);
    done      : out std_logic;
    violation : out std_logic
  );
end entity;

architecture rtl of polyvecl_chknorm is

  -- FSM state
  type state_type is (IDLE, START_POLY, WAIT_POLY, FINISH);
  signal state : state_type := IDLE;

  -- index poly
  signal idx : integer range 0 to L-1 := 0;

  -- signal trung gian cho poly hi?n t?i
  signal a_current : poly_t(0 to N-1);

  -- ?i?u khi?n poly_chknorm
  signal chknorm_start     : std_logic := '0';
  signal chknorm_done      : std_logic := '0';
  signal chknorm_violation : std_logic := '0';

  -- output
  signal viol_r : std_logic := '0';
  signal done_r : std_logic := '0';

begin
  violation <= viol_r;
  done      <= done_r;

  --------------------------------------------------------------------------
  -- Instance poly_chknorm cho poly hi?n t?i
  --------------------------------------------------------------------------
  poly_chknorm_inst : entity work.poly_chknorm
    generic map (N => N)
    port map (
      clk       => clk,
      rst       => rst,
      start     => chknorm_start,
      a         => a_current,     -- signal trung gian
      B         => B,
      done      => chknorm_done,
      violation => chknorm_violation
    );

  --------------------------------------------------------------------------
  -- Copy poly t? vector vào a_current
  --------------------------------------------------------------------------
  copy_current_poly: process(v, idx)
  begin
    for j in 0 to N-1 loop
      a_current(j) <= v(idx, j);
    end loop;
  end process;

  --------------------------------------------------------------------------
  -- FSM tu?n t? quét L poly
  --------------------------------------------------------------------------
  process(clk, rst)
  begin
    if rst = '1' then
      state           <= IDLE;
      idx             <= 0;
      chknorm_start   <= '0';
      viol_r          <= '0';
      done_r          <= '0';
    elsif rising_edge(clk) then
      -- m?c ??nh
      chknorm_start <= '0';
      done_r <= '0';

      case state is
        when IDLE =>
          if start = '1' then
            idx <= 0;
            viol_r <= '0';
            state <= START_POLY;
          end if;

        when START_POLY =>
          chknorm_start <= '1';
          state <= WAIT_POLY;

        when WAIT_POLY =>
          if chknorm_done = '1' then
            -- OR k?t qu? violation
            if chknorm_violation = '1' then
              viol_r <= '1';
            end if;

            -- next poly ho?c finish
            if idx = L-1 then
              state <= FINISH;
            else
              idx <= idx + 1;
              state <= START_POLY;
            end if;
          end if;

        when FINISH =>
          done_r <= '1';
          state <= IDLE;

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;

end architecture;
