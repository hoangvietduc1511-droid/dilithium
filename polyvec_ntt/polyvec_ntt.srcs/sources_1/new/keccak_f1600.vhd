-- ===================================================================
-- File: keccak_f1600.vhd
-- Single-round-per-cycle, synthesizable Keccak-f[1600].
-- Ports use state_t for direct connection to other modules.
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.keccak_pkg.all;

entity keccak_f1600 is
  port(
    clk      : in  std_logic;
    rst      : in  std_logic; -- synchronous active-high
    start    : in  std_logic; -- pulse for 1 clk to start when idle
    state_in : in  state_t;   -- input state (lane[0]..lane[24])
    busy     : out std_logic; -- high while running
    state_out: out state_t;   -- output state when done
    done     : out std_logic  -- one-cycle pulse when finished
  );
end entity keccak_f1600;

architecture rtl of keccak_f1600 is
  type rc_array_t is array(0 to NROUNDS-1) of lane_t;
  constant RC : rc_array_t := (
    x"0000000000000001", x"0000000000008082", x"800000000000808A", x"8000000080008000",
    x"000000000000808B", x"0000000080000001", x"8000000080008081", x"8000000000008009",
    x"000000000000008A", x"0000000000000088", x"0000000080008009", x"000000008000000A",
    x"000000008000808B", x"800000000000008B", x"8000000000008089", x"8000000000008003",
    x"8000000000008002", x"8000000000000080", x"000000000000800A", x"800000008000000A",
    x"8000000080008081", x"8000000000008080", x"0000000080000001", x"8000000080008008"
  );

  signal A       : state_t := (others => (others => '0'));
  signal round_i : integer range 0 to NROUNDS := 0;
  signal running : std_logic := '0';
  signal done_reg: std_logic := '0';

  function xor_lane(a,b: lane_t) return lane_t is
  begin
    return std_logic_vector(unsigned(a) xor unsigned(b));
  end function xor_lane;

begin
  busy <= running;
  done <= done_reg;

  process(clk)
    variable Aba, Abe, Abi, Abo, Abu : lane_t;
    variable Aga, Age, Agi, Ago, Agu : lane_t;
    variable Aka, Ake, Aki, Ako, Aku : lane_t;
    variable Ama, Ame, Ami, Amo, Amu : lane_t;
    variable Asa, Ase, Asi, Aso, Asu : lane_t;

    variable BCa, BCe, BCi, BCo, BCu : lane_t;
    variable Da, De, Di, Do, Du    : lane_t;

    variable Eba, Ebe, Ebi, Ebo, Ebu : lane_t;
    variable Ega, Ege, Egi, Ego, Egu : lane_t;
    variable Eka, Eke, Eki, Eko, Eku : lane_t;
    variable Ema, Eme, Emi, Emo, Emu : lane_t;
    variable Esa, Ese, Esi, Eso, Esu : lane_t;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        A <= (others => (others => '0'));
        round_i <= 0;
        running <= '0';
        done_reg <= '0';
        state_out <= (others => (others => '0'));
      else
        done_reg <= '0';
        if (start = '1') and (running = '0') then
          A <= state_in;
          round_i <= 0;
          running <= '1';
        elsif running = '1' then
          -- copy A into vars
          Aba := A(0);  Abe := A(1);  Abi := A(2);  Abo := A(3);  Abu := A(4);
          Aga := A(5);  Age := A(6);  Agi := A(7);  Ago := A(8);  Agu := A(9);
          Aka := A(10); Ake := A(11); Aki := A(12); Ako := A(13); Aku := A(14);
          Ama := A(15); Ame := A(16); Ami := A(17); Amo := A(18); Amu := A(19);
          Asa := A(20); Ase := A(21); Asi := A(22); Aso := A(23); Asu := A(24);

          -- theta
          BCa := xor_lane(xor_lane(Aba, Aga), xor_lane(Aka, xor_lane(Ama, Asa)));
          BCe := xor_lane(xor_lane(Abe, Age), xor_lane(Ake, xor_lane(Ame, Ase)));
          BCi := xor_lane(xor_lane(Abi, Agi), xor_lane(Aki, xor_lane(Ami, Asi)));
          BCo := xor_lane(xor_lane(Abo, Ago), xor_lane(Ako, xor_lane(Amo, Aso)));
          BCu := xor_lane(xor_lane(Abu, Agu), xor_lane(Aku, xor_lane(Amu, Asu)));

          Da := xor_lane(BCu, rol64(BCe,1));
          De := xor_lane(BCa, rol64(BCi,1));
          Di := xor_lane(BCe, rol64(BCo,1));
          Do := xor_lane(BCi, rol64(BCu,1));
          Du := xor_lane(BCo, rol64(BCa,1));

          Aba := xor_lane(Aba, Da);
          Age := xor_lane(Age, De);
          Aki := xor_lane(Aki, Di);
          Amo := xor_lane(Amo, Do);
          Asu := xor_lane(Asu, Du);

          -- rho/pi/chi/iota (unrolled for clarity)
          BCa := Aba; BCe := rol64(Age,44); BCi := rol64(Aki,43); BCo := rol64(Amo,21); BCu := rol64(Asu,14);
          Eba := xor_lane(BCa, xor_lane((not BCe), BCi));
          Eba := std_logic_vector(unsigned(Eba) xor unsigned(RC(round_i)));
          Ebe := xor_lane(BCe, xor_lane((not BCi), BCo));
          Ebi := xor_lane(BCi, xor_lane((not BCo), BCu));
          Ebo := xor_lane(BCo, xor_lane((not BCu), BCa));
          Ebu := xor_lane(BCu, xor_lane((not BCa), BCe));

          Abo := xor_lane(Abo, Do);
          Agu := xor_lane(Agu, Du);
          Aka := xor_lane(Aka, Da);
          Ame := xor_lane(Ame, De);
          Asi := xor_lane(Asi, Di);

          BCa := rol64(Abo,28); BCe := rol64(Agu,20); BCi := rol64(Aka,3); BCo := rol64(Ame,45); BCu := rol64(Asi,61);
          Ega := xor_lane(BCa, xor_lane((not BCe), BCi));
          Ege := xor_lane(BCe, xor_lane((not BCi), BCo));
          Egi := xor_lane(BCi, xor_lane((not BCo), BCu));
          Ego := xor_lane(BCo, xor_lane((not BCu), BCa));
          Egu := xor_lane(BCu, xor_lane((not BCa), BCe));

          Abe := xor_lane(Abe, De);
          Agi := xor_lane(Agi, Di);
          Ako := xor_lane(Ako, Do);
          Amu := xor_lane(Amu, Du);
          Asa := xor_lane(Asa, Da);

          BCa := rol64(Abe,1); BCe := rol64(Agi,6); BCi := rol64(Ako,25); BCo := rol64(Amu,8); BCu := rol64(Asa,18);
          Eka := xor_lane(BCa, xor_lane((not BCe), BCi));
          Eke := xor_lane(BCe, xor_lane((not BCi), BCo));
          Eki := xor_lane(BCi, xor_lane((not BCo), BCu));
          Eko := xor_lane(BCo, xor_lane((not BCu), BCa));
          Eku := xor_lane(BCu, xor_lane((not BCa), BCe));

          Abu := xor_lane(Abu, Du);
          Aga := xor_lane(Aga, Da);
          Ake := xor_lane(Ake, De);
          Ami := xor_lane(Ami, Di);
          Aso := xor_lane(Aso, Do);

          BCa := rol64(Abu,27); BCe := rol64(Aga,36); BCi := rol64(Ake,10); BCo := rol64(Ami,15); BCu := rol64(Aso,56);
          Ema := xor_lane(BCa, xor_lane((not BCe), BCi));
          Eme := xor_lane(BCe, xor_lane((not BCi), BCo));
          Emi := xor_lane(BCi, xor_lane((not BCo), BCu));
          Emo := xor_lane(BCo, xor_lane((not BCu), BCa));
          Emu := xor_lane(BCu, xor_lane((not BCa), BCe));

          Abi := xor_lane(Abi, Di);
          Ago := xor_lane(Ago, Do);
          Aku := xor_lane(Aku, Du);
          Ama := xor_lane(Ama, Da);
          Ase := xor_lane(Ase, De);

          BCa := rol64(Abi,62); BCe := rol64(Ago,55); BCi := rol64(Aku,39); BCo := rol64(Ama,41); BCu := rol64(Ase,2);
          Esa := xor_lane(BCa, xor_lane((not BCe), BCi));
          Ese := xor_lane(BCe, xor_lane((not BCi), BCo));
          Esi := xor_lane(BCi, xor_lane((not BCo), BCu));
          Eso := xor_lane(BCo, xor_lane((not BCu), BCa));
          Esu := xor_lane(BCu, xor_lane((not BCa), BCe));

          -- commit next state
          A(0)  <= Eba; A(1)  <= Ebe; A(2)  <= Ebi; A(3)  <= Ebo; A(4)  <= Ebu;
          A(5)  <= Ega; A(6)  <= Ege; A(7)  <= Egi; A(8)  <= Ego; A(9)  <= Egu;
          A(10) <= Eka; A(11) <= Eke; A(12) <= Eki; A(13) <= Eko; A(14) <= Eku;
          A(15) <= Ema; A(16) <= Eme; A(17) <= Emi; A(18) <= Emo; A(19) <= Emu;
          A(20) <= Esa; A(21) <= Ese; A(22) <= Esi; A(23) <= Eso; A(24) <= Esu;

          if round_i = NROUNDS-1 then
            running <= '0';
            done_reg <= '1';
            state_out <= (others => (others => '0'));
            -- output the just computed state (A updated above at next clock), so capture A after assignment
            state_out <= A;
            round_i <= 0;
          else
            round_i <= round_i + 1;
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture rtl;