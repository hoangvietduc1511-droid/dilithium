library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.poly_pkg.all;

entity poly_chknorm is
  generic (
    N : natural := 256
  );
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    start     : in  std_logic;
    a         : in  poly_t(0 to N-1);                      -- coeff_t from poly_pkg (signed)
    B         : in  unsigned(COEFF_WIDTH-1 downto 0);
    done      : out std_logic;
    violation : out std_logic
  );
end entity;

architecture rtl of poly_chknorm is
  constant HALF : integer := (Q - 1) / 2;
  type state_type is (IDLE, RUN, FINISH);
  signal state : state_type := IDLE;

  signal i       : integer range 0 to N := 0;
  signal viol_r  : std_logic := '0';
  signal done_r  : std_logic := '0';
begin

  violation <= viol_r;
  done      <= done_r;

  process(clk, rst)
    variable coeff_raw : integer;
    variable a_mod     : integer;
    variable t_val     : integer;
    variable B_int     : integer;
  begin
    if rst = '1' then
      state   <= IDLE;
      i       <= 0;
      viol_r  <= '0';
      done_r  <= '0';
    elsif rising_edge(clk) then
      -- default clear done (one-cycle pulse when FINISH)
      done_r <= '0';

      case state is
        when IDLE =>
          if start = '1' then
            i      <= 0;
            viol_r <= '0';
            state  <= RUN;
          end if;

        when RUN =>
          -- read coefficient (signed), normalize to [0, Q-1]
          coeff_raw := to_integer(a(i));
          a_mod := coeff_raw mod Q;
          if a_mod < 0 then
            a_mod := a_mod + Q;
          end if;

          -- compute t = min(a_mod, Q - a_mod)  (== |centered representative|)
          if a_mod <= HALF then
            t_val := a_mod;
          else
            t_val := Q - a_mod;
          end if;

          -- compare with B
          B_int := to_integer(unsigned(B));
          if t_val >= B_int then
            viol_r <= '1';
          end if;

          -- next index or finish
          if i = N-1 then
            state <= FINISH;
          else
            i <= i + 1;
          end if;

        when FINISH =>
          done_r <= '1';
          state  <= IDLE;

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;

end architecture;
