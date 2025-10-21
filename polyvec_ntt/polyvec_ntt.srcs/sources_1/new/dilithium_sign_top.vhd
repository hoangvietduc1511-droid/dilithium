library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- IMPORTANT: require poly_pkg defining poly types and conversion helpers
use work.poly_pkg.all;
--use work.polyveck_pkg.all;

entity dilithium_top is
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    rx     : in  std_logic;                        -- UART RX (from PC)
    tx     : out std_logic;                        -- UART TX (to PC)
    leds   : out std_logic_vector(3 downto 0)      -- debug LEDs
  );
end entity;

architecture Behavioral of dilithium_top is

  ----------------------------------------------------------------------------
  -- Constants (Dilithium I/II light)
  ----------------------------------------------------------------------------
  constant K_const : natural := 4;
  constant L_const : natural := 4;
  constant N_const : natural := 256;

  constant PAYLOAD_BYTES : integer := 64;
  constant PAYLOAD_BITS  : integer := PAYLOAD_BYTES * 8;

  ----------------------------------------------------------------------------
  -- Component declarations (m   ust match your actual files)
  ----------------------------------------------------------------------------
  component UART_TOP
    generic (
      DBITS     : integer := 8;
      SB_TICK   : integer := 16;
      BR_LIMIT  : integer := 87;
      BR_BITS   : integer := 10
    );
    port (
      clk          : in  std_logic;
      reset        : in  std_logic;
      rx           : in  std_logic;
      tx_start_in  : in  std_logic;
      data_tx      : in  std_logic_vector(7  downto 0);
      rx_done      : out std_logic;
      tx           : out std_logic;
      tx_done      : out std_logic;
      data_rx      : out std_logic_vector(7  downto 0)
    );
  end component;

  component shake256_core
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
  end component;

  component Expand_matA_wrapper
    port (
      ap_clk_0        : in  std_logic;
      ap_ctrl_0_done  : out std_logic;
      ap_ctrl_0_idle  : out std_logic;
      ap_ctrl_0_ready : out std_logic;
      ap_ctrl_0_start : in  std_logic;
      ap_rst_0        : in  std_logic;
      mat_address0_0  : out std_logic_vector ( 12 downto 0 );
      mat_ce0_0       : out std_logic;
      mat_d0_0        : out std_logic_vector ( 31 downto 0 );
      mat_we0_0       : out std_logic;
      rho_address0_0  : out std_logic_vector ( 4 downto 0 );
      rho_ce0_0       : out std_logic;
      rho_q0_0        : in  std_logic_vector ( 7 downto 0 )
    );
  end component;

  component polyvecl_ntt
    generic ( L : natural := 4; N : natural := 256 );
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      start : in  std_logic;
      v_in  : in  polyvec_t(0 to L-1, 0 to N-1);
      done  : out std_logic;
      v_out : out polyvec_t(0 to L-1, 0 to N-1)
    );
  end component;

  component polyveck_ntt
    generic ( K : natural := 4; N : natural := 256 );
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      start : in  std_logic;
      v_in  : in  polyvec_t(0 to K-1, 0 to N-1);
      done  : out std_logic;
      v_out : out polyvec_t(0 to K-1, 0 to N-1)
    );
  end component;

  component poly_uniform_gamma1m1
    generic ( N_COEFF : integer := 256; COEFF_W : integer := 32; GAMMA1 : integer := 8380417 );
    port (
      clk    : in  std_logic;
      rst    : in  std_logic;
      start  : in  std_logic;
      key    : in  std_logic_vector(255 downto 0);
      nonce  : in  std_logic_vector(7 downto 0);
      done   : out std_logic;
      coeffs : out std_logic_vector(N_COEFF*COEFF_W-1 downto 0)
    );
  end component;

  component polyveck_freeze
    generic ( K : natural := 4; N : natural := 256 );
    port(
      clk   : in  std_logic;
      v_in  : in  polyvec_t(0 to K-1, 0 to N-1);
      v_out : out polyvec_t(0 to K-1, 0 to N-1)
    );
  end component;

  component polyvecl_freeze
    generic ( L : natural := 4; N : natural := 256 );
    port(
      clk   : in  std_logic;
      l_in  : in  polyvec_t(0 to L-1, 0 to N-1);
      l_out : out polyvec_t(0 to L-1, 0 to N-1)
    );
  end component;

  component polyveck_decompose
    port(
      clk    : in  std_logic;
      rst    : in  std_logic;
      v_in   : in  coeff_array32;
      v0_out : out coeff_array32;
      v1_out : out coeff_array4
    );
  end component;

  component poly_ntt
    generic ( N : natural := 256 );
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      start : in  std_logic;
      a_in  : in  poly_t(0 to N-1);
      done  : out std_logic;
      a_out : out poly_t(0 to N-1)
    );
  end component;

  component polyvecl_add
    generic ( L : natural := 4; N : natural := 256 );
    port (
      u_in  : in  polyvec_t(0 to L-1, 0 to N-1);
      v_in  : in  polyvec_t(0 to L-1, 0 to N-1);
      w_out : out polyvec_t(0 to L-1, 0 to N-1)
    );
  end component;

  component polyveck_add
    generic ( K : natural := 4; N : natural := 256 );
    port (
      u_in  : in  polyvec_t(0 to K-1, 0 to N-1);
      v_in  : in  polyvec_t(0 to K-1, 0 to N-1);
      w_out : out polyvec_t(0 to K-1, 0 to N-1)
    );
  end component;

  component polyvecl_chknorm
    generic ( L : natural := 4; N : natural := 256 );
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      start     : in  std_logic;
      v         : in  polyvec_t(0 to L-1, 0 to N-1);
      B         : in  unsigned(COEFF_WIDTH-1 downto 0);
      done      : out std_logic;
      violation : out std_logic
    );
  end component;

  component polyveck_chknorm
    generic ( K : natural := 4; N : natural := 256 );
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      start     : in  std_logic;
      v         : in  polyvec_t(0 to K-1, 0 to N-1);
      B         : in  unsigned(COEFF_WIDTH-1 downto 0);
      done      : out std_logic;
      violation : out std_logic
    );
  end component;

  component polyveck_sub
    generic ( N : natural := 256; K : natural := 4 );
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      start : in  std_logic;
      done  : out std_logic;
      u     : in  polyvec_t(0 to K-1, 0 to N-1);
      v     : in  polyvec_t(0 to K-1, 0 to N-1);
      w     : out polyvec_t(0 to K-1, 0 to N-1)
    );
  end component;

  component polyveck_neg
    generic ( K : natural := 4; N : natural := 256; Q : integer := 8380417 );
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      start : in  std_logic;
      done  : out std_logic;
      v_in  : in  polyvec_t(0 to K-1, 0 to N-1);
      v_out : out polyvec_t(0 to K-1, 0 to N-1)
    );
  end component;

  component polyveck_make_hint
    generic ( K : natural := 4; N : natural := 256 );
    port (
       clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
        u_vec : in  unsigned(32*K*N - 1 downto 0);
        v_vec : in  unsigned(32*K*N - 1 downto 0);
        done  : out std_logic;
        h_vec : out std_logic_vector(K*N - 1 downto 0);
        s_out : out unsigned(15 downto 0)  -- t?ng s? bit 1
    );
  end component;

  ----------------------------------------------------------------------------
  -- Internal signals
  ----------------------------------------------------------------------------
  -- UART
  signal uart_rx_done : std_logic;
  signal uart_tx_done : std_logic;
  signal uart_tx_start: std_logic := '0'; -- pulse (1 cycle) to start tx
  signal uart_data_tx : std_logic_vector(7 downto 0) := (others => '0');
  signal uart_data_rx : std_logic_vector(7 downto 0);

  -- command + payload
  signal cmd_reg      : std_logic_vector(7 downto 0) := (others => '0');
  signal rx_count     : integer range 0 to PAYLOAD_BYTES := 0;
  signal payload_in   : std_logic_vector(PAYLOAD_BITS-1 downto 0) := (others => '0');
  signal have_payload : std_logic := '0';

  -- start/done lines for each core
  signal start_01, done_01 : std_logic := '0';
  signal start_02, done_02 : std_logic := '0';
  signal start_03, done_03 : std_logic := '0';
  signal start_04, done_04 : std_logic := '0';
  signal start_05, done_05 : std_logic := '0';
  signal start_06, done_06 : std_logic := '0';
  signal start_07, done_07 : std_logic := '0';
  signal start_08, done_08 : std_logic := '0';
  signal start_09, done_09 : std_logic := '0';
  signal start_0A, done_0A : std_logic := '0';
  signal start_0B, done_0B : std_logic := '0';
  signal start_0C, done_0C : std_logic := '0';
  signal start_0D, done_0D : std_logic := '0';
  signal start_0E, done_0E : std_logic := '0';
  signal start_0F, done_0F : std_logic := '0';
  signal start_10, done_10 : std_logic := '0';

  -- SHAKE signals
  signal shake_msg     : std_logic_vector(8*1024-1 downto 0) := (others => '0');
  signal shake_msg_len : natural := 0;
  signal shake_absorb_done  : std_logic := '0';
  signal shake_squeeze_start : std_logic := '0';
  signal shake_outlen : natural := 512; -- request 512-bit output in this example
  signal shake_out_data : std_logic_vector(8*1024-1 downto 0) := (others => '0');
  signal shake_squeeze_done : std_logic := '0';

  -- Expand_matA interface signals (wrapper)
  signal expand_start_sig : std_logic := '0';
  signal expand_done_sig  : std_logic := '0';
  signal expand_idle_sig  : std_logic;
  signal expand_ready_sig : std_logic;
  signal mat_address0_0 : std_logic_vector(12 downto 0);
  signal mat_ce0_0      : std_logic;
  signal mat_d0_0       : std_logic_vector(31 downto 0);
  signal mat_we0_0      : std_logic;
  signal rho_address0_0 : std_logic_vector(4 downto 0);
  signal rho_ce0_0      : std_logic;
  signal rho_q0_0       : std_logic_vector(7 downto 0);

  -- polyvec typed signals (K=L=4, N=256)
  signal pv_l_in   : polyvec_t(0 to L_const-1, 0 to N_const-1) := (others => (others => (others => '0')));
  signal pv_l_out  : polyvec_t(0 to L_const-1, 0 to N_const-1);
  signal pv_k_in   : polyvec_t(0 to K_const-1, 0 to N_const-1) := (others => (others => (others => '0')));
  signal pv_k_out  : polyvec_t(0 to K_const-1, 0 to N_const-1);

  -- poly_uniform
  signal pu_key    : std_logic_vector(255 downto 0) := (others => '0');
  signal pu_nonce  : std_logic_vector(7 downto 0) := (others => '0');
  signal pu_done_s : std_logic := '0';
  signal pu_coeffs : std_logic_vector(256*32-1 downto 0) := (others => '0');

  -- decompose outputs
  signal pv_decomp_in  : coeff_array32;
  signal pv_decomp_v0  : coeff_array32;
  signal pv_decomp_v1  : coeff_array4;

  -- poly a
  signal poly_a_in  :  poly_t(0 to N-1);
  signal poly_a_out :  poly_t(0 to N-1);

  -- add/sub outputs
  signal pv_add_u  : polyvec_t(0 to L_const-1, 0 to N_const-1);
  signal pv_add_v  : polyvec_t(0 to L_const-1, 0 to N_const-1);
  signal pv_add_w  : polyvec_t(0 to L_const-1, 0 to N_const-1);

  signal pv_k_u : polyvec_t(0 to K_const-1, 0 to N_const-1);
  signal pv_k_v : polyvec_t(0 to K_const-1, 0 to N_const-1);
  signal pv_k_w : polyvec_t(0 to K_const-1, 0 to N_const-1);

  -- chknorm
  signal chknorm_violation : std_logic := '0';

  -- hint
  signal u_vec_big, v_vec_big : unsigned(32*K_const*N_const - 1 downto 0) := (others => '0');
  signal hint_vec : std_logic_vector(K_const*N_const - 1 downto 0);
  signal hint_sout : unsigned(15 downto 0);

  -- muxed outputs to UART
  signal done_sel : std_logic;
  signal dout_sel : std_logic_vector(PAYLOAD_BITS-1 downto 0) := (others => '0');

  -- internal LED reg
  signal leds_reg : std_logic_vector(3 downto 0) := (others => '0');

  -- FSM
  type top_state_type is (WAIT_CMD, RECV_PAYLOAD, START_CORE, WAIT_DONE, SEND_RESP);
  signal top_state : top_state_type := WAIT_CMD;

  -- UART send counters/buffer
  signal tx_send_index : integer range 0 to PAYLOAD_BYTES := 0;
  signal resp_status   : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_buf        : std_logic_vector(PAYLOAD_BITS-1 downto 0) := (others => '0');

  -- internal RX bookkeeping for recv_proc
  signal rx_byte_index : integer range 0 to PAYLOAD_BYTES := 0;

begin

  ----------------------------------------------------------------------------
  -- Instantiate UART_TOP
  ----------------------------------------------------------------------------
  uart_inst : UART_TOP
    generic map (
      DBITS    => 8,
      SB_TICK  => 16,
      BR_LIMIT => 87,
      BR_BITS  => 10
    )
    port map (
      clk         => clk,
      reset       => reset,
      rx          => rx,
      tx_start_in => uart_tx_start,
      data_tx     => uart_data_tx,
      rx_done     => uart_rx_done,
      tx          => tx,
      tx_done     => uart_tx_done,
      data_rx     => uart_data_rx
    );

  ----------------------------------------------------------------------------
  -- Receive process: simple protocol (CMD + 64-byte payload)
  -- This process latches incoming bytes from UART_TOP (1 byte per rx_done).
  ----------------------------------------------------------------------------
  recv_proc : process(clk, reset)
    variable tmp_payload: std_logic_vector(PAYLOAD_BITS-1 downto 0);
  begin
    if reset = '1' then
      cmd_reg <= (others => '0');
      rx_count <= 0;
      rx_byte_index <= 0;
      have_payload <= '0';
      payload_in <= (others => '0');
      tmp_payload := (others => '0');
    elsif rising_edge(clk) then
      if uart_rx_done = '1' then
        -- First byte after idle is command
        if rx_byte_index = 0 then
          cmd_reg <= uart_data_rx;
          rx_byte_index <= 1;
          rx_count <= 0;
          have_payload <= '0';
        else
          -- store incoming byte at appropriate position (MSB-first packing to match pack_outputs)
          tmp_payload((PAYLOAD_BITS-1) - rx_count*8 downto (PAYLOAD_BITS-8) - rx_count*8) := uart_data_rx;
          rx_count <= rx_count + 1;
          rx_byte_index <= rx_byte_index + 1;
          if rx_count + 1 = PAYLOAD_BYTES then
            payload_in <= tmp_payload;
            have_payload <= '1';
            rx_byte_index <= 0;
            rx_count <= 0;
            tmp_payload := (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- Unpack payload -> typed signals
  -- Adapt to your exact packing order used by PC side.
  ----------------------------------------------------------------------------
  unpack_proc : process(clk, reset)
  begin
    if reset = '1' then
      shake_msg <= (others => '0');
      shake_msg_len <= 0;
      pu_key <= (others => '0');
      pu_nonce <= (others => '0');
    elsif rising_edge(clk) then
      if have_payload = '1' then
        -- Example: place received 512 bits into top-of-shake_msg
        shake_msg(8*1024-1 downto 8*1024-512) <= payload_in;
        shake_msg_len <= PAYLOAD_BYTES; -- 64 bytes
        -- Example: first 32 bytes of payload used as key for poly_uniform
        pu_key <= payload_in(PAYLOAD_BITS-1 downto PAYLOAD_BITS-256);
        -- Example: nonce = next byte (if you want)
        pu_nonce <= payload_in(PAYLOAD_BITS-257 downto PAYLOAD_BITS-264);
        -- (other unpackings may be performed here)
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- Instantiate all cores
  ----------------------------------------------------------------------------
  shake_inst : shake256_core
    port map (
      clk => clk,
      rst => reset,
      msg => shake_msg,
      msg_len => shake_msg_len,
      absorb_start => start_01,
      absorb_done => shake_absorb_done,
      squeeze_start => shake_squeeze_start,
      outlen => shake_outlen,
      out_data => shake_out_data,
      squeeze_done => shake_squeeze_done
    );

  -- bind done_01 to SHAKE squeeze_done (this is our "done" for command 0x01)
  done_01 <= shake_squeeze_done;

  expand_inst : Expand_matA_wrapper
    port map (
      ap_clk_0 => clk,
      ap_ctrl_0_start => start_02,
      ap_ctrl_0_done  => expand_done_sig,
      ap_ctrl_0_idle  => expand_idle_sig,
      ap_ctrl_0_ready => expand_ready_sig,
      ap_rst_0 => reset,
      mat_address0_0 => mat_address0_0,
      mat_ce0_0 => mat_ce0_0,
      mat_d0_0 => mat_d0_0,
      mat_we0_0 => mat_we0_0,
      rho_address0_0 => rho_address0_0,
      rho_ce0_0 => rho_ce0_0,
      rho_q0_0 => rho_q0_0
    );

  polyvecl_ntt_inst : polyvecl_ntt
    generic map ( L => L_const, N => N_const )
    port map (
      clk => clk,
      reset => reset,
      start => start_03,
      v_in => pv_l_in,
      done => done_03,
      v_out => pv_l_out
    );

  polyveck_ntt_inst : polyveck_ntt
    generic map ( K => K_const, N => N_const )
    port map (
      clk => clk,
      reset => reset,
      start => start_04,
      v_in => pv_k_in,
      done => done_04,
      v_out => pv_k_out
    );

  poly_uniform_inst : poly_uniform_gamma1m1
    generic map ( N_COEFF => N_const, COEFF_W => 32, GAMMA1 => 8380417 )
    port map (
      clk => clk,
      rst => reset,
      start => start_05,
      key => pu_key,
      nonce => pu_nonce,
      done => done_05,
      coeffs => pu_coeffs
    );

  polyveck_freeze_inst : polyveck_freeze
    generic map ( K => K_const, N => N_const )
    port map (
      clk => clk,
      v_in => pv_k_in,
      v_out => pv_k_out
    );

  polyvecl_freeze_inst : polyvecl_freeze
    generic map ( L => L_const, N => N_const )
    port map (
      clk => clk,
      l_in => pv_l_in,
      l_out => pv_l_out
    );

  polyveck_decompose_inst : polyveck_decompose
    port map (
      clk => clk,
      rst => reset,
      v_in => pv_decomp_in,
      v0_out => pv_decomp_v0,
      v1_out => pv_decomp_v1
    );

  poly_ntt_inst : poly_ntt
    generic map ( N => N_const )
    port map (
      clk => clk,
      reset => reset,
      start => start_09,
      a_in => poly_a_in,
      done => done_09,
      a_out => poly_a_out
    );

  polyvecl_add_inst : polyvecl_add
    generic map ( L => L_const, N => N_const )
    port map (
      u_in => pv_add_u,
      v_in => pv_add_v,
      w_out => pv_add_w
    );

  polyveck_add_inst : polyveck_add
    generic map ( K => K_const, N => N_const )
    port map (
      u_in => pv_k_u,
      v_in => pv_k_v,
      w_out => pv_k_w
    );

  polyvecl_chknorm_inst : polyvecl_chknorm
    generic map ( L => L_const, N => N_const )
    port map (
      clk => clk,
      rst => reset,
      start => start_0C,
      v => pv_l_in,
      B => (others => '0'),
      done => done_0C,
      violation => chknorm_violation
    );

  polyveck_chknorm_inst : polyveck_chknorm
    generic map ( K => K_const, N => N_const )
    port map (
      clk => clk,
      rst => reset,
      start => start_0D,
      v => pv_k_in,
      B => (others => '0'),
      done => done_0D,
      violation => chknorm_violation
    );

  polyveck_sub_inst : polyveck_sub
    generic map ( N => N_const, K => K_const )
    port map (
      clk => clk,
      rst => reset,
      start => start_0E,
      done => done_0E,
      u => pv_k_u,
      v => pv_k_v,
      w => pv_k_w
    );

  polyveck_neg_inst : polyveck_neg
    generic map ( K => K_const, N => N_const, Q => 8380417 )
    port map (
      clk => clk,
      rst => reset,
      start => start_0F,
      done => done_0F,
      v_in => pv_k_in,
      v_out => pv_k_out
    );

  polyveck_make_hint_inst : polyveck_make_hint
    generic map ( K => K_const, N => N_const )
    port map (
      clk => clk,
      rst => reset,
      start => start_10,
      u_vec => u_vec_big,
      v_vec => v_vec_big,
      done => done_10,
      h_vec => hint_vec,
      s_out => hint_sout
    );

  ----------------------------------------------------------------------------
  -- DONE selection (mux)
  ----------------------------------------------------------------------------
  done_sel <= done_01 when cmd_reg = x"01" else
              expand_done_sig when cmd_reg = x"02" else
              done_03 when cmd_reg = x"03" else
              done_04 when cmd_reg = x"04" else
              done_05 when cmd_reg = x"05" else
              done_06 when cmd_reg = x"06" else
              done_07 when cmd_reg = x"07" else
              done_08 when cmd_reg = x"08" else
              done_09 when cmd_reg = x"09" else
              done_0A when cmd_reg = x"0A" else
              done_0B when cmd_reg = x"0B" else
              done_0C when cmd_reg = x"0C" else
              done_0D when cmd_reg = x"0D" else
              done_0E when cmd_reg = x"0E" else
              done_0F when cmd_reg = x"0F" else
              done_10 when cmd_reg = x"10" else
              '0';
    
---------------------------------------------------------------------------- 
-- Pack outputs into 512-bit payload (you must implement conversions) 
------------------------------------------------------------------------
    pack_outputs : process(cmd_reg, shake_out_data, mat_d0_0, pv_l_out, pv_k_out, pu_coeffs)
    begin
      dout_sel <= (others => '0'); -- default
      case cmd_reg is
        when x"01" =>
          -- 512-bit slice from SHAKE (MSB-aligned)
          dout_sel <= shake_out_data(8*1024-1 downto 8*1024-512);
        when x"02" =>
          -- example: clear then place mat_d0_0 into top 32 bits
          dout_sel <= (others => '0');
          dout_sel(511 downto 480) <= mat_d0_0;
        when x"03" =>
          -- use helper function that must return 512-bit vector
          dout_sel <= polyvec_to_sv512(pv_l_out);
        when x"04" =>
          dout_sel <= polyvec_to_sv512(pv_k_out);
        when x"05" =>
          dout_sel <= pu_coeffs((256*32)-1 downto (256*32)-512);
        when others =>
          dout_sel <= (others => '0');
      end case;
    end process;

  ----------------------------------------------------------------------------
  -- Generate start signals when FSM in START_CORE
  ----------------------------------------------------------------------------
  start_01 <= '1' when (top_state = START_CORE and cmd_reg = x"01") else '0';
  start_02 <= '1' when (top_state = START_CORE and cmd_reg = x"02") else '0';
  start_03 <= '1' when (top_state = START_CORE and cmd_reg = x"03") else '0';
  start_04 <= '1' when (top_state = START_CORE and cmd_reg = x"04") else '0';
  start_05 <= '1' when (top_state = START_CORE and cmd_reg = x"05") else '0';
  start_06 <= '1' when (top_state = START_CORE and cmd_reg = x"06") else '0';
  start_07 <= '1' when (top_state = START_CORE and cmd_reg = x"07") else '0';
  start_08 <= '1' when (top_state = START_CORE and cmd_reg = x"08") else '0';
  start_09 <= '1' when (top_state = START_CORE and cmd_reg = x"09") else '0';
  start_0A <= '1' when (top_state = START_CORE and cmd_reg = x"0A") else '0';
  start_0B <= '1' when (top_state = START_CORE and cmd_reg = x"0B") else '0';
  start_0C <= '1' when (top_state = START_CORE and cmd_reg = x"0C") else '0';
  start_0D <= '1' when (top_state = START_CORE and cmd_reg = x"0D") else '0';
  start_0E <= '1' when (top_state = START_CORE and cmd_reg = x"0E") else '0';
  start_0F <= '1' when (top_state = START_CORE and cmd_reg = x"0F") else '0';
  start_10 <= '1' when (top_state = START_CORE and cmd_reg = x"10") else '0';

  ----------------------------------------------------------------------------
  -- FSM: WAIT_CMD -> RECV_PAYLOAD -> START_CORE -> WAIT_DONE -> SEND_RESP
  ----------------------------------------------------------------------------
  fsm_proc : process(clk, reset)
    variable send_pulse_req : std_logic := '0';
  begin
    if reset = '1' then
      top_state <= WAIT_CMD;
      uart_tx_start <= '0';
      uart_data_tx <= (others => '0');
      tx_send_index <= 0;
      resp_status <= (others => '0');
      leds_reg <= (others => '0');
      have_payload <= '0';
      tx_buf <= (others => '0');
      send_pulse_req := '0';
    elsif rising_edge(clk) then
      -- default clear 1-cycle pulse (UART start)
      if uart_tx_start = '1' then
        -- ensure it's only one clock-cycle wide
        uart_tx_start <= '0';
      end if;

      case top_state is
        when WAIT_CMD =>
          leds_reg <= "0001";
          -- wait for a full payload to be received (have_payload asserted by recv_proc)
          if have_payload = '1' then
            top_state <= START_CORE;
          end if;

        when START_CORE =>
          leds_reg <= "0010";
          -- start signal is combinational from cmd_reg -> cores above
          -- Reset response bookkeeping
          resp_status <= (others => '0');
          tx_send_index <= 0;
          tx_buf <= (others => '0');
          -- If command is SHAKE and needs squeeze start instead of absorb,
          -- controller could set shake_squeeze_start here (example)
          -- but we use start_01 to indicate to SHAKE to do its flow internally.
          top_state <= WAIT_DONE;

        when WAIT_DONE =>
          leds_reg <= "0100";
          if done_sel = '1' then
            tx_buf <= dout_sel;
            resp_status <= x"AA"; -- success code (example)
            tx_send_index <= 0;
            top_state <= SEND_RESP;
          end if;

        when SEND_RESP =>
          leds_reg <= "1000";
          -- Send status byte then payload bytes (total PAYLOAD_BYTES+1 frames)
          -- We generate a single-cycle pulse uart_tx_start when sending a new byte.
          if uart_tx_done = '1' then
            -- previous byte finished sending; ready to start next
            if tx_send_index = 0 then
              -- send status byte
              uart_data_tx <= resp_status;
              uart_tx_start <= '1'; -- 1-cycle pulse
              tx_send_index <= tx_send_index + 1;
            elsif tx_send_index <= PAYLOAD_BYTES then
              -- send payload bytes one by one (MSB-first)
              uart_data_tx <= tx_buf(PAYLOAD_BITS-1 - (tx_send_index-1)*8 downto PAYLOAD_BITS-8 - (tx_send_index-1)*8);
              uart_tx_start <= '1';
              tx_send_index <= tx_send_index + 1;
            else
              -- finished sending
              have_payload <= '0';
              tx_send_index <= 0;
              top_state <= WAIT_CMD;
            end if;
          else
            -- if tx_done is not high, but we have not started any send yet (edge case on first entry),
            -- start first byte. This handles the case uart_tx_done is '1' at reset and then '0'.
            if tx_send_index = 0 and uart_tx_done = '0' then
              -- attempt to send status byte (if UART is ready it will assert tx_done after())
              uart_data_tx <= resp_status;
              uart_tx_start <= '1';
              tx_send_index <= 1;
            end if;
          end if;

        when others =>
          top_state <= WAIT_CMD;
      end case;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- Drive leds output
  ----------------------------------------------------------------------------
  leds <= leds_reg;

end architecture Behavioral;
