-- ===================================================================
-- File: tb_polyvecl_add.vhd
-- Description: Testbench ki?m tra c?ng hai vector ?a th?c
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.poly_pkg.all;

entity tb_polyvecl_add is
end entity;

architecture sim of tb_polyvecl_add is

  --------------------------------------------------------------------
  -- C?u hình tham s?
  --------------------------------------------------------------------
  constant L : natural := 4;     -- s? l??ng ?a th?c trong vector
  constant N : natural := 8;     -- s? h? s? trong m?i ?a th?c (nh? ?? d? quan sát)

  --------------------------------------------------------------------
  -- Tín hi?u k?t n?i DUT
  --------------------------------------------------------------------
  signal u_in  : polyvec_t(0 to L-1, 0 to N-1);
  signal v_in  : polyvec_t(0 to L-1, 0 to N-1);
  signal w_out : polyvec_t(0 to L-1, 0 to N-1);

begin

  --------------------------------------------------------------------
  -- DUT instance
  --------------------------------------------------------------------
  DUT: entity work.polyvecl_add
    generic map (
      L => L,
      N => N
    )
    port map (
      u_in  => u_in,
      v_in  => v_in,
      w_out => w_out
    );

  --------------------------------------------------------------------
  -- Test process
  --------------------------------------------------------------------
  stim_proc: process
  begin
    report "=== B?t ??u ki?m tra polyvecl_add ===";

    ----------------------------------------------------------------
    -- Gán d? li?u ??u vào
    ----------------------------------------------------------------
    for i in 0 to L-1 loop
      for j in 0 to N-1 loop
        u_in(i,j) <= to_signed(i + j, COEFF_WIDTH);
        v_in(i,j) <= to_signed((i * 2) + j, COEFF_WIDTH);
      end loop;
    end loop;

    wait for 10 ns;

    ----------------------------------------------------------------
    -- In ra k?t qu? (v?i waveform ho?c console)
    ----------------------------------------------------------------
    for i in 0 to L-1 loop
      for j in 0 to N-1 loop
        report "w_out(" & integer'image(i) & "," & integer'image(j) & ") = " &
               integer'image(to_integer(w_out(i,j))) &
               " = " &
               integer'image(to_integer(u_in(i,j))) & " + " &
               integer'image(to_integer(v_in(i,j)));
      end loop;
    end loop;

    report "=== K?t thúc ki?m tra polyvecl_add ===";
    wait;
  end process;

end architecture sim;
