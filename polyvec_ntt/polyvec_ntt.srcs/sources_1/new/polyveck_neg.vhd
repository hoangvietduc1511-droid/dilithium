library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.poly_pkg.all;

entity polyveck_neg is
    generic (
        K : natural := 4;          -- s? l??ng ?a th?c trong vector
        N : natural := 256;        -- s? h? s? m?i ?a th?c
        Q : integer := 8380417     -- Modulus Q
    );
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
        done  : out std_logic;
        v_in  : in  polyvec_t(0 to K-1, 0 to N-1);
        v_out : out polyvec_t(0 to K-1, 0 to N-1)
    );
end entity;

architecture rtl of polyveck_neg is
    type state_t is (IDLE, LOAD, PULSE_START, CLEAR_START, WAIT_DONE, CAPTURE, FINISH);
    signal state      : state_t := IDLE;

    signal k_idx      : integer range 0 to K-1 := 0;
    signal start_poly : std_logic := '0';
    signal done_poly  : std_logic := '0';

    signal a_in_poly  : poly_t(0 to N-1);
    signal a_out_poly : poly_t(0 to N-1);

    signal v_reg      : polyvec_t(0 to K-1, 0 to N-1);
begin

    -- Instance of poly_neg (module con)
    u_poly_neg : entity work.poly_neg
        generic map (
            N => N,
            Q => Q
        )
        port map (
            clk   => clk,
            rst   => rst,
            start => start_poly,
            done  => done_poly,
            a_in  => a_in_poly,
            a_out => a_out_poly
        );

    -- Controller: load (element-wise), pulse, wait, capture (element-wise)
    process(clk, rst)
        variable j : integer;
    begin
        if rst = '1' then
            state <= IDLE;
            k_idx <= 0;
            start_poly <= '0';
            done <= '0';
            v_reg <= (others => (others => (others => '0')));

        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    done <= '0';
                    start_poly <= '0';
                    if start = '1' then
                        k_idx <= 0;
                        state <= LOAD;
                    end if;

                when LOAD =>
                    -- copy element-wise v_in(k_idx, j) -> a_in_poly(j)
                    for j in 0 to N-1 loop
                        a_in_poly(j) <= v_in(k_idx, j);
                    end loop;
                    -- ??m b?o a_in_poly ?n ??nh ? chu k? sau -> pulse start_poly
                    state <= PULSE_START;

                when PULSE_START =>
                    start_poly <= '1';   -- pulse 1 cycle
                    state <= CLEAR_START;

                when CLEAR_START =>
                    start_poly <= '0';
                    state <= WAIT_DONE;

                when WAIT_DONE =>
                    if done_poly = '1' then
                        state <= CAPTURE;
                    end if;

                when CAPTURE =>
                    -- copy element-wise a_out_poly -> v_reg(k_idx, j)
                    for j in 0 to N-1 loop
                        v_reg(k_idx, j) <= a_out_poly(j);
                    end loop;

                    -- next index or finish
                    if k_idx = K-1 then
                        state <= FINISH;
                    else
                        k_idx <= k_idx + 1;
                        state <= LOAD;   -- load next poly in next cycle
                    end if;

                when FINISH =>
                    done <= '1';
                    -- gi? done = '1' cho ??n khi start ???c clear (tùy yêu c?u)
                    if start = '0' then
                        done <= '0';
                        state <= IDLE;
                    end if;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

    v_out <= v_reg;

end architecture;
