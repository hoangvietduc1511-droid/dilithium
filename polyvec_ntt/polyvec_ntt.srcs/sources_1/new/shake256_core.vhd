-- ===================================================================
-- File: shake256_core.vhd
-- Synthesizable absorb/squeeze controller (supports arbitrary msg_len and outlen limited by buffers)
-- Designed for simulation and synthesis. Uses FSM to handshake with keccak_f1600.
-- ===================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.keccak_pkg.all;

--entity shake256_core is
--  port(
--    clk : in std_logic;
--    rst : in std_logic;

--    msg         : in  std_logic_vector(8*1024-1 downto 0);
--    msg_len     : in  natural; -- bytes
--    absorb_start: in  std_logic;
--    absorb_done : out std_logic;

--    squeeze_start: in std_logic;
--    outlen       : in natural; -- bytes
--    out_data     : out std_logic_vector(8*1024-1 downto 0);
--    squeeze_done : out std_logic
--  );
--end entity;

entity shake256_core is
   port(
     clk : in std_logic;
     rst : in std_logic;
     msg : in std_logic_vector(8*1024-1 downto 0);
     msg_len : in natural;
     absorb_start : in std_logic;
     absorb_done : out std_logic;
     squeeze_start : in std_logic;
     outlen : in natural;
     out_data : out std_logic_vector(8*1024-1 downto 0);
     squeeze_done : out std_logic
   );
 end entity;
architecture rtl of shake256_core is
  component keccak_f1600
    port(
      clk      : in std_logic; rst: in std_logic; start: in std_logic;
      state_in : in state_t; busy: out std_logic; state_out: out state_t; done: out std_logic
    );
  end component;

  signal perm_start : std_logic := '0';
  signal perm_busy  : std_logic := '0';
  signal perm_done  : std_logic := '0';
  signal perm_state : state_t := (others => (others => '0'));

  signal state_reg  : state_t := (others => (others => '0'));

  type fsm_t is (IDLE, ABSORB_XOR, PERM_WAIT, PAD_XOR, FINAL_PERM_WAIT, ABSORB_DONE_ST, SQUEEZE_COPY, SQUEEZE_PERM_WAIT, SQUEEZE_DONE_ST);
  signal state_fsm : fsm_t := IDLE;

  signal mpos      : natural := 0;
  signal remaining : natural := 0;
  signal outpos    : natural := 0;
  signal nblocks   : natural := 0;
  signal tail      : natural := 0;

  function get_byte(big: std_logic_vector; idx: natural) return std_logic_vector is
  begin
    return big((idx+1)*8-1 downto idx*8);
  end function;

  -- helper to build 64-bit lane from msg bytes (little-endian) safely
  function build_lane_from_msg(big: std_logic_vector; base_idx: natural; limit: natural) return lane_t is
    variable r : lane_t := (others => '0');
    variable bidx : natural;
  begin
    for i in 0 to 7 loop
      bidx := base_idx + i;
      if bidx < limit then
        r(8*(i+1)-1 downto 8*i) := get_byte(big, bidx);
      else
        r(8*(i+1)-1 downto 8*i) := (others => '0');
      end if;
    end loop;
    return r;
  end function;

  -- output buffer (internal)
  signal out_buf : std_logic_vector(8*1024-1 downto 0) := (others => '0');

begin
  U_PERM: keccak_f1600
    port map(clk => clk, rst => rst, start => perm_start, state_in => perm_state, busy => perm_busy, state_out => perm_state, done => perm_done);

  absorb_done <= '1' when state_fsm = ABSORB_DONE_ST else '0';
  squeeze_done <= '1' when state_fsm = SQUEEZE_DONE_ST else '0';
  out_data <= out_buf;

  process(clk)
    variable lane_idx : integer;
    variable tmp64    : lane_t;
    variable tbase    : natural;
    variable tbyte    : std_logic_vector(7 downto 0);
    variable lane     : lane_t;
    variable i        : integer;
    variable byte_idx : integer;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state_fsm <= IDLE;
        state_reg <= (others => (others => '0'));
        perm_start <= '0';
        perm_state <= (others => (others => '0'));
        mpos <= 0; remaining <= 0; outpos <= 0;
        out_buf <= (others => '0');
      else
        case state_fsm is
          when IDLE =>
            perm_start <= '0';
            if absorb_start = '1' then
              mpos <= 0;
              remaining <= msg_len;
              state_reg <= (others => (others => '0'));
              state_fsm <= ABSORB_XOR;
            elsif squeeze_start = '1' then
              -- prepare squeeze using current state_reg
              outpos <= 0;
              nblocks <= outlen / SHAKE256_RATE;
              tail <= outlen - nblocks*SHAKE256_RATE;
              perm_state <= state_reg;
              state_fsm <= SQUEEZE_COPY;
            end if;

          when ABSORB_XOR =>
            if remaining >= SHAKE256_RATE then
              -- XOR full block into state_reg
              for lane_idx in 0 to (SHAKE256_RATE/8 - 1) loop
                tmp64 := build_lane_from_msg(msg, mpos + lane_idx*8, msg_len);
                state_reg(lane_idx) <= std_logic_vector(unsigned(state_reg(lane_idx)) xor unsigned(tmp64));
              end loop;
              -- start permutation (pulse)
              perm_state <= state_reg;
              perm_start <= '1';
              state_fsm <= PERM_WAIT;
            else
              -- need to pad and XOR remaining (<r)
              state_fsm <= PAD_XOR;
            end if;

          when PERM_WAIT =>
            perm_start <= '0';
            if perm_busy = '0' and perm_done = '1' then
              -- capture permuted state
              state_reg <= perm_state;
              -- advance pointers
              mpos <= mpos + SHAKE256_RATE;
              remaining <= remaining - SHAKE256_RATE;
              if remaining = 0 then
                state_fsm <= ABSORB_DONE_ST;
              else
                state_fsm <= ABSORB_XOR;
              end if;
            end if;

          when PAD_XOR =>
            -- build padded block t[r]
            tbase := mpos;
            for lane_idx in 0 to (SHAKE256_RATE/8 - 1) loop
              lane := (others => '0');
              for i in 0 to 7 loop
                if (tbase + lane_idx*8 + i) < msg_len then
                  tbyte := get_byte(msg, tbase + lane_idx*8 + i);
                elsif (tbase + lane_idx*8 + i) = msg_len then
                  tbyte := x"1F"; -- domain
                else
                  tbyte := (others => '0');
                end if;
                lane(8*(i+1)-1 downto 8*i) := tbyte;
              end loop;
              -- last byte of block: set MSB (0x80)
              if lane_idx = (SHAKE256_RATE/8 - 1) then
                lane(63) := '1';
              end if;
              state_reg(lane_idx) <= std_logic_vector(unsigned(state_reg(lane_idx)) xor unsigned(lane));
            end loop;
            -- final permutation start
            perm_state <= state_reg;
            perm_start <= '1';
            state_fsm <= FINAL_PERM_WAIT;

          when FINAL_PERM_WAIT =>
            perm_start <= '0';
            if perm_busy = '0' and perm_done = '1' then
              state_reg <= perm_state;
              state_fsm <= ABSORB_DONE_ST;
            end if;

          when ABSORB_DONE_ST =>
            -- stay here until host clears absorb_start
            if absorb_start = '0' then
              state_fsm <= IDLE;
            end if;

          when SQUEEZE_COPY =>
            if nblocks > 0 then
              -- copy current state_reg lanes to out_buf at outpos
              for lane_idx in 0 to (SHAKE256_RATE/8 - 1) loop
                out_buf((outpos + lane_idx*8 + 1)*8 -1 downto (outpos + lane_idx*8)*8) <= state_reg(lane_idx);
              end loop;
              outpos <= outpos + SHAKE256_RATE;
              -- permute for next block
              perm_state <= state_reg;
              perm_start <= '1';
              nblocks <= nblocks - 1;
              state_fsm <= SQUEEZE_PERM_WAIT;
            else
              -- handle tail
              if tail > 0 then
                -- copy from state_reg to out_buf only tail bytes
                for lane_idx in 0 to (SHAKE256_RATE/8 - 1) loop
                  for i in 0 to 7 loop
                    byte_idx := lane_idx*8 + i;
                    if byte_idx < tail then
                      out_buf((outpos + byte_idx +1)*8 -1 downto (outpos + byte_idx)*8) <= state_reg(lane_idx)(8*(i+1)-1 downto 8*i);
                    end if;
                  end loop;
                end loop;
                outpos <= outpos + tail;
              end if;
              state_fsm <= SQUEEZE_DONE_ST;
            end if;

          when SQUEEZE_PERM_WAIT =>
            perm_start <= '0';
            if perm_busy = '0' and perm_done = '1' then
              state_reg <= perm_state;
              state_fsm <= SQUEEZE_COPY;
            end if;

          when SQUEEZE_DONE_ST =>
            -- remain here until host clears squeeze_start
            if squeeze_start = '0' then
              state_fsm <= IDLE;
            end if;

          when others =>
            state_fsm <= IDLE;
        end case;
      end if;
    end if;
  end process;
end architecture rtl;
