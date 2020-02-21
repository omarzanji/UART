library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Transmit is
    Port (
    CLK : in std_logic;
    err_sw : in std_logic_vector (1 downto 0) := "00";
    EN_b : in std_logic;
    --rst_b : in std_logic;
    tx_serial : out std_logic;
    Din : in std_logic_vector (3 downto 0));
end UART_Transmit;

architecture rtl of UART_Transmit is
    signal clks_per_bit : integer := 651;  -- 6.25e6 / 9600
    signal start : std_logic := '0';
    signal data_out : std_logic_vector (7 downto 0);
    signal data_reg : std_logic_vector (7 downto 0);
    signal bit_cnt : integer := 0;
    signal clk_cnt : integer := 0;
    signal clk_tx : std_logic;
    signal data_out_err : std_logic_vector (7 downto 0);
    
    -- for clk_divider:
    signal clk_rx : std_logic;
    signal reset : std_logic;
    signal locked : std_logic;

    type states is (idle, sending, stopping, cleanup);
    signal cs : states;
    -- signal nextState : states := idle;

    component clk_wiz_0
    port
     (
      clk_rx        : out    std_logic;
      clk_tx        : out    std_logic;
      reset         : in     std_logic;
      locked        : out    std_logic;
      clk           : in     std_logic);
    end component;

    component encode is
        Port (
            Din : in std_logic_vector (3 downto 0);
            Dout : out std_logic_vector (7 downto 0));
    end component;


begin

    clk_div : clk_wiz_0
       port map (
       clk_rx => clk_rx,
       clk_tx => clk_tx,
       reset => reset,
       locked => locked,
       clk => clk);

    encoder : encode
        port map (Din => Din, Dout => data_out);

    data_out_err(7 downto 6) <= data_out(7 downto 6);
    data_out_err(5) <= data_out(5) XOR err_sw(1);
    data_out_err(4) <= data_out(4);
    data_out_err(3) <= data_out(3) XOR err_sw(0);
    data_out_err(2 downto 0) <= data_out(2 downto 0);

    U_TX: process(clk_tx)
    begin
    case cs is
        when idle =>
            if (EN_b = '1') then
                start  <= '1';
                data_reg <= data_out_err;
                tx_serial <= '0';
                cs <= sending;
            else
                tx_serial <= '1';
            end if;

        when sending =>
            if (clk_cnt < clks_per_bit - 1)  then
                clk_cnt <= clk_cnt + 1;
                cs <= sending;
            else
                clk_cnt <= 0;
                tx_serial <= data_reg(0);
                data_reg <= std_logic_vector(shift_right(unsigned(data_reg), 1));
                bit_cnt <= bit_cnt + 1;
                if (bit_cnt = 7) then
                    cs <= stopping;
                else
                    cs <= sending;
                end if;
            end if;

        when stopping =>
            if (clk_cnt < clks_per_bit - 1)  then
                clk_cnt <= clk_cnt + 1;
                cs <= stopping;
            else
                clk_cnt <= 0;
                tx_serial <= '1';  -- stop bit
                cs <= cleanup;
            end if;

        when cleanup =>
            if (clk_cnt < clks_per_bit - 1)  then
                clk_cnt <= clk_cnt + 1;
                cs <= cleanup;
            else
                clk_cnt <= 0;
                tx_serial <= '1';
                start <= '0';
                bit_cnt <= 0;
                cs <= idle;
            end if;

    end case;
    end process;

end rtl;
