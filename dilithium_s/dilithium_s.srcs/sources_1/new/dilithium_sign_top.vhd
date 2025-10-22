library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- IMPORTANT: require poly_pkg defining poly types and conversion helpers
use work.poly_pkg.all;

entity dilithium_sign_top is
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    rx     : in  std_logic;                        -- UART RX (from PC)
    tx     : out std_logic                         -- UART TX (to PC)
  );
end entity dilithium_sign_top;

architecture Behavioral of dilithium_sign_top is

  ----------------------------------------------------------------------------
  -- Constants (Dilithium lite parameters) - kept for compatibility
  ----------------------------------------------------------------------------
  constant K_const : natural := 4;
  constant L_const : natural := 4;
  constant N_const : natural := 256;

  ----------------------------------------------------------------------------
  -- Component declarations (must match your actual files)
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
      data_rx      : out std_logic_vector(7 downto 0)
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
      key    : in  std_logic_vector(639 downto 0);  -- 80 bytes
      nonce  : in  std_logic_vector(15 downto 0);   -- 2 bytes
      done   : out std_logic;
      coeffs : out std_logic_vector(N_COEFF*COEFF_W-1 downto 0)
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

  ----------------------------------------------------------------------------
  -- Internal signals
  ----------------------------------------------------------------------------
  -- UART (using UART_TOP single module)
  signal uart_rx_done  : std_logic := '0';
  signal uart_tx_done  : std_logic := '0';
  signal uart_tx_start : std_logic := '0'; -- pulse (1 cycle) to start tx
  signal uart_data_tx  : std_logic_vector(7 downto 0) := (others => '0');
  signal uart_data_rx  : std_logic_vector(7 downto 0) := (others => '0');

  -- SHAKE signals
  signal shake_msg         : std_logic_vector(8*1024-1 downto 0) := (others => '0');
  signal shake_msg_len     : natural := 0;
  signal shake_absorb_done : std_logic := '0';
  signal shake_squeeze_start : std_logic := '0';
  signal shake_outlen      : natural := 384;
  signal shake_out_data    : std_logic_vector(8*1024-1 downto 0) := (others => '0');
  signal shake_squeeze_done: std_logic := '0';

  -- Expand wrapper interface
  signal expand_done_sig  : std_logic := '0';
  signal expand_idle_sig  : std_logic := '0';
  signal expand_ready_sig : std_logic := '0';
  signal mat_address0_0   : std_logic_vector(12 downto 0) := (others => '0');
  signal mat_ce0_0        : std_logic := '0';
  signal mat_d0_0         : std_logic_vector(31 downto 0) := (others => '0');
  signal mat_we0_0        : std_logic := '0';
  signal rho_address0_0   : std_logic_vector(4 downto 0) := (others => '0');
  signal rho_ce0_0        : std_logic := '0';
  signal rho_q0_0         : std_logic_vector(7 downto 0) := (others => '0');

  -- polyvec typed signals (K=L=4, N=256)
  signal pv_l_in   : polyvec_t(0 to L_const-1, 0 to N_const-1) := (others => (others => (others => '0')));
  signal pv_l_out  : polyvec_t(0 to L_const-1, 0 to N_const-1);
  signal pv_k_in   : polyvec_t(0 to K_const-1, 0 to N_const-1) := (others => (others => (others => '0')));
  signal pv_k_out  : polyvec_t(0 to K_const-1, 0 to N_const-1);

  -- poly_uniform
  signal pu_key    : std_logic_vector(639 downto 0) := (others => '0');
  signal pu_nonce  : std_logic_vector(15 downto 0) := (others => '0');
  signal pu_done_s : std_logic := '0';
  signal pu_coeffs : std_logic_vector(256*32-1 downto 0) := (others => '0');

  -- add/sub outputs (placeholders)
  signal pv_add_u  : polyvec_t(0 to L_const-1, 0 to N_const-1);
  signal pv_add_v  : polyvec_t(0 to L_const-1, 0 to N_const-1);
  signal pv_add_w  : polyvec_t(0 to L_const-1, 0 to N_const-1);

  signal pv_k_u : polyvec_t(0 to K_const-1, 0 to N_const-1);
  signal pv_k_v : polyvec_t(0 to K_const-1, 0 to N_const-1);
  signal pv_k_w : polyvec_t(0 to K_const-1, 0 to N_const-1);

  ----------------------------------------------------------------------------
  -- Control / FSM signals (host-controlled)
  ----------------------------------------------------------------------------
  -- start pulses for each IP (single-cycle pulses)
  signal start_shake   : std_logic := '0';
  signal start_expand  : std_logic := '0';
  signal start_vecl    : std_logic := '0';
  signal start_veck    : std_logic := '0';
  signal start_gamma   : std_logic := '0';

  -- done signals alias from modules
  signal done_shake    : std_logic := '0';
  signal done_expand   : std_logic := '0';
  signal done_vecl     : std_logic := '0';
  signal done_veck     : std_logic := '0';
  signal done_gamma    : std_logic := '0';

  -- pulse generator internal
  signal tx_start_p    : std_logic := '0'; -- request to start UART (one-cycle)
  signal tx_sent_ack   : std_logic := '0';

  -- command latch
  signal cmd_byte      : std_logic_vector(7 downto 0) := (others => '0');

  -- host-controlled FSM
  type hc_state_t is (
    HC_IDLE,
    HC_WAIT_CMD,
    HC_RUN_SHAKE,
    HC_RUN_EXPAND,
    HC_RUN_VECL,
    HC_RUN_VECK,
    HC_RUN_GAMMA,
    HC_SEND_ACK
  );
  signal hc_state, hc_next : hc_state_t := HC_IDLE;

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
  -- Instantiate other cores
  ----------------------------------------------------------------------------
  shake_inst : shake256_core
    port map (
      clk => clk,
      rst => reset,
      msg => shake_msg,
      msg_len => shake_msg_len,
      absorb_start => start_shake,
      absorb_done => shake_absorb_done,
      squeeze_start => shake_squeeze_start,
      outlen => shake_outlen,
      out_data => shake_out_data,
      squeeze_done => shake_squeeze_done
    );

  expand_inst : Expand_matA_wrapper
    port map (
      ap_clk_0 => clk,
      ap_ctrl_0_start => start_expand,
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
      start => start_vecl,
      v_in => pv_l_in,
      done => done_vecl,
      v_out => pv_l_out
    );

  polyveck_ntt_inst : polyveck_ntt
    generic map ( K => K_const, N => N_const )
    port map (
      clk => clk,
      reset => reset,
      start => start_veck,
      v_in => pv_k_in,
      done => done_veck,
      v_out => pv_k_out
    );

  poly_uniform_inst : poly_uniform_gamma1m1
    generic map ( N_COEFF => N_const, COEFF_W => 32, GAMMA1 => 8380417 )
    port map (
      clk => clk,
      rst => reset,
      start => start_gamma,
      key => pu_key,
      nonce => pu_nonce,
      done => done_gamma,
      coeffs => pu_coeffs
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

  ----------------------------------------------------------------------------
  -- Hook module done aliases (some module outputs already match signals)
  ----------------------------------------------------------------------------
  -- shake_absorb_done connected to shake_inst, use as done_shake
  done_shake  <= shake_absorb_done;
  done_expand <= expand_done_sig;
  -- done_vecl, done_veck, done_gamma assigned via instantiation outputs above

  ----------------------------------------------------------------------------
  -- UART tx pulse generator / ack capture
  -- Convert tx_start_p (request) -> uart_tx_start (1-cycle)
  ----------------------------------------------------------------------------
  uart_tx_pulse_proc: process(clk, reset)
  begin
    if reset = '1' then
      uart_tx_start <= '0';
      tx_sent_ack <= '0';
      uart_data_tx <= (others => '0');
    elsif rising_edge(clk) then
      -- one-cycle pulse generation
      if tx_start_p = '1' then
        uart_tx_start <= '1';
        tx_start_p <= '0';
      else
        uart_tx_start <= '0';
      end if;

      -- latch data onto uart when starting
      if uart_tx_start = '1' then
        uart_data_tx <= uart_data_tx; -- already set by FSM when requesting send
      end if;

      -- capture tx_done from UART_TOP as ack pulse
      if uart_tx_done = '1' then
        tx_sent_ack <= '1';
      else
        tx_sent_ack <= '0';
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- Host-controlled FSM (combinational + sequential style)
  ----------------------------------------------------------------------------
  -- sequential part: state update and single-cycle start pulses
  ----------------------------------------------------------------------------
  hc_seq: process(clk, reset)
  begin
    if reset = '1' then
      hc_state <= HC_IDLE;
      start_shake <= '0';
      start_expand <= '0';
      start_vecl <= '0';
      start_veck <= '0';
      start_gamma <= '0';
      uart_data_tx <= (others => '0');
      tx_start_p <= '0';
      cmd_byte <= (others => '0');
    elsif rising_edge(clk) then
      hc_state <= hc_next;

      -- default clear one-cycle start pulses
      start_shake <= '0';
      start_expand <= '0';
      start_vecl <= '0';
      start_veck <= '0';
      start_gamma <= '0';

      -- default clear tx request (handled when needed)
      tx_start_p <= '0';

      case hc_state is
        when HC_IDLE =>
          null; -- wait for command

        when HC_WAIT_CMD =>
          null;

        when HC_RUN_SHAKE =>
          -- assert single-cycle start
          start_shake <= '1';

        when HC_RUN_EXPAND =>
          start_expand <= '1';

        when HC_RUN_VECL =>
          start_vecl <= '1';

        when HC_RUN_VECK =>
          start_veck <= '1';

        when HC_RUN_GAMMA =>
          start_gamma <= '1';

        when HC_SEND_ACK =>
          -- request UART send (uart_data_tx must already be set)
          tx_start_p <= '1';

        when others =>
          null;
      end case;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- hc_next combinational logic
  ----------------------------------------------------------------------------
  hc_comb: process(hc_state, uart_rx_done, uart_data_rx, done_shake, done_expand, done_vecl, done_veck, done_gamma, tx_sent_ack)
  begin
    -- default
    hc_next <= hc_state;

    case hc_state is
      when HC_IDLE =>
        -- move to waiting for commands
        hc_next <= HC_WAIT_CMD;

      when HC_WAIT_CMD =>
        if uart_rx_done = '1' then
          cmd_byte <= uart_data_rx; -- latch command
          case uart_data_rx is
            when x"53" =>   -- 'S' : SHAKE
              hc_next <= HC_RUN_SHAKE;
            when x"45" =>   -- 'E' : EXPAND
              hc_next <= HC_RUN_EXPAND;
            when x"56" =>   -- 'V' : VEC NTT
              hc_next <= HC_RUN_VECL;
            when x"4B" =>   -- 'K' : VECK NTT
              hc_next <= HC_RUN_VECK;
            when x"47" =>   -- 'G' : GAMMA (poly_uniform)
              hc_next <= HC_RUN_GAMMA;
            when others =>
              -- unknown command: remain in wait (could send NACK)
              hc_next <= HC_WAIT_CMD;
          end case;
        else
          hc_next <= HC_WAIT_CMD;
        end if;

      when HC_RUN_SHAKE =>
        -- after asserting start_shake for one cycle, wait for done
        if done_shake = '1' then
          -- prepare ack as same byte 'S' and send
          uart_data_tx <= x"53";
          hc_next <= HC_SEND_ACK;
        else
          hc_next <= HC_RUN_SHAKE;
        end if;

      when HC_RUN_EXPAND =>
        if done_expand = '1' then
          uart_data_tx <= x"45";
          hc_next <= HC_SEND_ACK;
        else
          hc_next <= HC_RUN_EXPAND;
        end if;

      when HC_RUN_VECL =>
        if done_vecl = '1' then
          uart_data_tx <= x"56";
          hc_next <= HC_SEND_ACK;
        else
          hc_next <= HC_RUN_VECL;
        end if;

      when HC_RUN_VECK =>
        if done_veck = '1' then
          uart_data_tx <= x"4B";
          hc_next <= HC_SEND_ACK;
        else
          hc_next <= HC_RUN_VECK;
        end if;

      when HC_RUN_GAMMA =>
        if done_gamma = '1' then
          uart_data_tx <= x"47";
          hc_next <= HC_SEND_ACK;
        else
          hc_next <= HC_RUN_GAMMA;
        end if;

      when HC_SEND_ACK =>
        -- request uart send and wait ack (tx_done)
        if tx_sent_ack = '1' then
          -- ack has been transmitted: return to WAIT_CMD
          hc_next <= HC_WAIT_CMD;
        else
          hc_next <= HC_SEND_ACK;
        end if;

      when others =>
        hc_next <= HC_WAIT_CMD;
    end case;
  end process;

  ----------------------------------------------------------------------------
  -- Optional: simple rho read mapping from shake_out_data for Expand_matA
  -- (If Expand_matA wrapper asserts rho_ce0_0 and rho_address0_0, we provide bytes)
  ----------------------------------------------------------------------------
  rho_read_proc: process(clk)
    variable idx : integer;
    variable hi  : integer;
    variable lo  : integer;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        rho_q0_0 <= (others => '0');
      else
        if rho_ce0_0 = '1' then
          idx := to_integer(unsigned(rho_address0_0));
          hi := (idx + 1) * 8 - 1;
          lo := idx * 8;
          if hi <= shake_out_data'left and lo >= 0 then
            rho_q0_0 <= shake_out_data(hi downto lo);
          else
            rho_q0_0 <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- Tie add inputs to avoid warnings (simple wiring, can be changed)
  ----------------------------------------------------------------------------
  pv_add_u <= pv_l_out;
  pv_add_v <= pv_l_in;
  pv_k_u <= pv_k_out;
  pv_k_v <= pv_k_in;

  ----------------------------------------------------------------------------
  -- end architecture
  ----------------------------------------------------------------------------
end architecture Behavioral;
