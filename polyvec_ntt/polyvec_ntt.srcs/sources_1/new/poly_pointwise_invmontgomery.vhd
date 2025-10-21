library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity poly_pointwise_invmontgomery is
  generic (
    N : natural := 256
  );
  port (
    clk   : in  std_logic;
    reset : in  std_logic;               -- active '1'
    start : in  std_logic;               -- pulse to start
    a_in  : in  poly_t(0 to N-1);
    b_in  : in  poly_t(0 to N-1);
    c_out : out poly_t(0 to N-1);
    done  : out std_logic
  );
end entity;

architecture rtl of poly_pointwise_invmontgomery is
  signal c_reg   : poly_t(0 to N-1) := (others => (others => '0'));
  signal idx     : integer range 0 to N := 0;
  signal running : std_logic := '0';
  signal done_reg: std_logic := '0';
begin

  process(clk, reset)
    variable prod64 : unsigned(63 downto 0);
    variable tmp    : coeff_t;
  begin
    if reset = '1' then
      c_reg    <= (others => (others => '0'));
      idx      <= 0;
      running  <= '0';
      done_reg <= '0';
    elsif rising_edge(clk) then
      if (start = '1') and (running = '0') then
        idx <= 0;
        running <= '1';
        done_reg <= '0';
      elsif running = '1' then
        -- compute one coefficient
        prod64 := resize(unsigned(a_in(idx)), 64) * resize(unsigned(b_in(idx)), 64);
        tmp := montgomery_reduce(prod64);
        c_reg(idx) <= reduce32(tmp);

        if idx = N-1 then
          running <= '0';
          done_reg <= '1';
        else
          idx <= idx + 1;
        end if;
      else
        done_reg <= '0';
      end if;
    end if;
  end process;

  c_out <= c_reg;
  done  <= done_reg;

end architecture;
