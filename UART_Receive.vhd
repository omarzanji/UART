library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Receive is
    Port (
    clk : in std_logic;
    rx_serial : in std_logic;
    rx_data_reg : inout std_logic_vector (7 downto 0);
    LEDS : out std_logic_vector (1 downto 0);
    Segments : out std_logic_vector (6 downto 0));
end UART_Receive;

architecture rtl of UART_Receive is
    signal clks_per_bit : integer := 5208;  -- 50e6 / 9600

    signal errorLEDS : std_logic_vector (1 downto 0);
    signal OG_data : std_logic_vector (3 downto 0);
    signal data : std_logic_vector(3 downto 0);

    signal clk_rx : std_logic;
    signal rx_data_R : std_logic;
    signal rx_data : std_logic;

    signal clk_cnt : integer := 0;
    signal bit_cnt : integer := 0;

    -- for clk_divider:
    signal clk_tx : std_logic;
    signal reset : std_logic;
    signal locked : std_logic;

    type states is (idle, starting, receiving, stopping);
    signal cs : states;

    component clk_wiz_0
    port
     (
      clk_rx        : out    std_logic;
      clk_tx        : out    std_logic;
      reset         : in     std_logic;
      locked        : out    std_logic;
      clk           : in     std_logic);
    end component;

    component decode is
     Port (
         dIn: in std_logic_vector (7 downto 0);
         errorLEDS: out std_logic_vector (1 downto 0);
         dataOut: out std_logic_vector (3 downto 0));
     end component;

     component display is
       Port (
            Segments : out STD_LOGIC_VECTOR(6 downto 0);
            D: in STD_LOGIC_VECTOR(3 downto 0));
     end component;

begin

    clk_div : clk_wiz_0
       port map (
           clk_rx => clk_rx,
           clk_tx => clk_tx,
           reset => reset,
           locked => locked,
           clk => clk);

    decoder : decode
        port map (
            dIn => rx_data_reg, errorLEDS => errorLEDS,
            dataOut => OG_data);

    disp : display
        port map (
            Segments => Segments, D => data);

    sample : process(clk_rx)
    begin
       if rising_edge(clk_rx) then
           rx_data_R <= rx_serial;
           rx_data <= rx_data_R;
       end if;
    end process;


    U_RX : process(clk_rx)
    begin
    case cs is
        when idle =>
            LEDS <= errorLEDS;
            data <= OG_data;
            if (rx_data = '0') then
                cs <= starting;
            else
                cs <= idle;
            end if;

        when starting =>
            if (clk_cnt = (clks_per_bit - 1) / 2) then
                if (rx_data = '0') then
                    clk_cnt <= 0;
                    cs <= receiving;
                else
                    cs <= idle;
                end if;
            else
                clk_cnt <= clk_cnt + 1;
                cs <= starting;
            end if;

        when receiving =>
            if (clk_cnt < clks_per_bit - 1) then
                clk_cnt <= clk_cnt + 1;
                cs <= receiving;
            else
                clk_cnt <= 0;
                rx_data_reg(bit_cnt) <= rx_data;
                if (bit_cnt = 7) then
                    cs <= stopping;
                else
                    bit_cnt <= bit_cnt + 1;
                    cs <= receiving;
                end if;
            end if;

        when stopping =>
            if (clk_cnt < clks_per_bit - 1) then
                clk_cnt <= clk_cnt + 1;
                cs <= stopping;
            else
                clk_cnt <= 0;
                bit_cnt <= 0;
                cs <= idle;
            end if;

    end case;
    end process;


end rtl;
