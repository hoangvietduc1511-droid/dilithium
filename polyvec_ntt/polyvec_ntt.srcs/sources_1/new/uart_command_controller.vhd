library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_command_controller is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        rx_valid    : in  std_logic;
        rx_data     : in  std_logic_vector(7 downto 0);
        tx_busy     : in  std_logic;
        tx_start    : out std_logic;
        tx_data     : out std_logic_vector(7 downto 0);
        cmd_code    : out std_logic_vector(7 downto 0);
        start_core  : out std_logic;
        done_core   : in  std_logic;
        data_in     : out std_logic_vector(511 downto 0);
        data_out    : in  std_logic_vector(511 downto 0)
    );
end uart_command_controller;

architecture Behavioral of uart_command_controller is
    type state_type is (IDLE, RECV_CMD, RECV_DATA, WAIT_DONE, SEND_DATA);
    signal state     : state_type := IDLE;
    signal byte_cnt  : integer range 0 to 63 := 0;
    signal din_buf   : std_logic_vector(511 downto 0) := (others => '0');
    signal dout_buf  : std_logic_vector(511 downto 0) := (others => '0');
    signal tx_buf    : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_flag   : std_logic := '0';
begin

    tx_data  <= tx_buf;
    tx_start <= tx_flag;
    data_in  <= din_buf;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                cmd_code <= (others => '0');
                start_core <= '0';
                byte_cnt <= 0;
                tx_flag <= '0';
            else
                tx_flag <= '0';
                start_core <= '0';

                case state is
                    when IDLE =>
                        if rx_valid = '1' then
                            cmd_code <= rx_data;
                            state <= RECV_DATA;
                            byte_cnt <= 0;
                        end if;

                    when RECV_DATA =>
                        if rx_valid = '1' then
                            din_buf((511 - 8*byte_cnt) downto (504 - 8*byte_cnt)) <= rx_data;
                            if byte_cnt = 63 then
                                start_core <= '1';
                                state <= WAIT_DONE;
                            else
                                byte_cnt <= byte_cnt + 1;
                            end if;
                        end if;

                    when WAIT_DONE =>
                        if done_core = '1' then
                            dout_buf <= data_out;
                            byte_cnt <= 0;
                            state <= SEND_DATA;
                        end if;

                    when SEND_DATA =>
                        if tx_busy = '0' then
                            tx_flag <= '1';
                            tx_buf <= dout_buf((511 - 8*byte_cnt) downto (504 - 8*byte_cnt));
                            if byte_cnt = 63 then
                                state <= IDLE;
                            else
                                byte_cnt <= byte_cnt + 1;
                            end if;
                        end if;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
