-- ===================================================================
-- File: keccak_pkg.vhd
-- ===================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package keccak_pkg is
  constant NROUNDS       : integer := 24;
  constant SHAKE256_RATE : natural := 136; -- bytes

  subtype lane_t is std_logic_vector(63 downto 0);
  type state_t is array(0 to 24) of lane_t;

  function rol64(a : lane_t; offset : natural) return lane_t;
end package keccak_pkg;

package body keccak_pkg is
  function rol64(a : lane_t; offset : natural) return lane_t is
    variable u : unsigned(63 downto 0) := unsigned(a);
    variable o : natural := offset mod 64;
    variable r : unsigned(63 downto 0);
  begin
    if o = 0 then
      r := u;
    else
      r := (u sll o) or (u srl (64 - o));
    end if;
    return std_logic_vector(r);
  end function rol64;
end package body keccak_pkg;
