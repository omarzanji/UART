library ieee;
use ieee.std_logic_1164.all;

entity top is
    Port (
        clk : in std_logic);
end top;

architecture Behavioral of top is

    signal Din : std_logic_vector (3 downto 0) := "1000";
    signal EN_b : std_logic;
  --  signal rst_b : std_logic := '0';
    signal serial : std_logic;
    signal rx_data_reg : std_logic_vector (7 downto 0);

    component UART_Transmit is
        Port (
        clk : in std_logic;
        err_sw : in std_logic_vector (1 downto 0) := "00";
        EN_b : in std_logic;
       -- rst_b : in std_logic;
        tx_serial : out std_logic;
        Din : in std_logic_vector (3 downto 0));
    end component;

    component UART_Receive is
        Port (
        clk : in std_logic;
        rx_serial : in std_logic;
        rx_data_reg : inout std_logic_vector (7 downto 0));
    end component;

begin

    TX : UART_Transmit
        port map (
            clk => clk, EN_b => EN_b,
             tx_serial => serial,
            Din => Din);

    RX : UART_Receive
        port map (
            clk => clk, rx_serial => serial, rx_data_reg => rx_data_reg);


end architecture;
