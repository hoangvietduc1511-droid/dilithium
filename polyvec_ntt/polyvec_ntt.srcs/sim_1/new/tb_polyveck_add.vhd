-- ===================================================================
-- File: tb_polyveck_add.vhd
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity tb_polyveck_add is
end entity;

architecture sim of tb_polyveck_add is

  constant K : natural := 4;
  constant N : natural := 8;

  signal u_in  : polyvec_t(0 to K-1, 0 to N-1);
  signal v_in  : polyvec_t(0 to K-1, 0 to N-1);
  signal w_out : polyvec_t(0 to K-1, 0 to N-1);

begin

  DUT: entity work.polyveck_add
    generic map (
      K => K,
      N => N
    )
    port map (
      u_in  => u_in,
      v_in  => v_in,
      w_out => w_out
    );

  process
  begin
    report "=== B?t ??u ki?m tra polyveck_add ===";

    -- Sinh d? li?u test
    for i in 0 to K-1 loop
      for j in 0 to N-1 loop
        u_in(i,j) <= to_signed(i + j, COEFF_WIDTH);
        v_in(i,j) <= to_signed((i * 3) + j, COEFF_WIDTH);
      end loop;
    end loop;

    wait for 10 ns;

    -- In k?t qu?
    for i in 0 to K-1 loop
      for j in 0 to N-1 loop
        report "w_out(" & integer'image(i) & "," & integer'image(j) & ") = " &
               integer'image(to_integer(w_out(i,j))) &
               " = " &
               integer'image(to_integer(u_in(i,j))) & " + " &
               integer'image(to_integer(v_in(i,j)));
      end loop;
    end loop;

    report "=== K?t thúc ki?m tra polyveck_add ===";
    wait;
  end process;

end architecture sim;
