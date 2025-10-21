library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_TOP is
    generic (
        DBITS     : integer := 8;      -- number of data bits in a word
        SB_TICK   : integer := 16;     -- number of stop bit / oversampling ticks
        BR_LIMIT  : integer := 87;    -- baud rate generator counter limit
        BR_BITS   : integer := 10      -- number of baud rate generator counter bits
    );
    port (
        clk          : in  std_logic;                     -- FPGA clock
        reset        : in  std_logic;                     -- reset
        rx           : in  std_logic;                     -- serial data in
        tx_start_in  : in  std_logic;
        data_tx      : in std_logic_vector(DBITS-1 downto 0);
        rx_done      : out std_logic;                     -- do not write data to FIFO
        tx           : out std_logic;                     -- serial data out
        tx_done      : out std_logic;    
        data_rx      : out std_logic_vector(DBITS-1 downto 0) -- data to Rx FIFO
    );
end entity UART_TOP;

architecture behavioral of UART_TOP is
    -- Connection Signals
    signal tick             : std_logic;                      -- sample tick from baud rate generator
 
    -- Instantiation of baudrate generator
    component baudrate_generator
        generic (
            CLOCK_FREQ : integer := 100000000; 
            BAUD_RATE  : integer := 115200  
        );
        port (
            clk         : in std_logic;
            reset       : in std_logic;
            tick        : out std_logic
        );
    end component;

    -- Instantiation of UART RX
    component UART_rx
        port (
            clk           : in std_logic;
            reset         : in std_logic;
            baud_tick     : in std_logic;
            rx            : in std_logic;
            rx_done       : out std_logic;
            rx_data       : out std_logic_vector(DBITS-1 downto 0)
        );
    end component;

    -- Instantiation of UART TX
    component UART_tx
        port (
            clk           : in std_logic;
            reset         : in std_logic;
            baud_tick     : in std_logic;
            tx_start      : in std_logic;
            tx_data       : in std_logic_vector(DBITS-1 downto 0);
            tx            : out std_logic;
            tx_done       : out std_logic
        );
    end component;


begin
    -- Baud rate generator instantiation
    baudrate_gen_inst : baudrate_generator
        generic map (
            CLOCK_FREQ => 100000000,   -- 100 MHz system clock
            BAUD_RATE  => 115200
        )
        port map (
            clk    => clk,
            reset  => reset,
            tick   => tick
        );

    -- UART Receiver instantiation
    uart_rx_inst : UART_rx
        port map (
            clk       => clk,
            reset     => reset,
            baud_tick => tick,
            rx        => rx,
            rx_done   => rx_done,
            rx_data   => data_rx
        );

    -- UART Transmitter instantiation
    uart_tx_inst : UART_tx
        port map (
            clk       => clk,
            reset     => reset,
            baud_tick => tick,
            tx_start  => tx_start_in,          
            tx_data   => data_tx,           
            tx        => tx,
            tx_done   => tx_done
        );
        
end architecture behavioral;