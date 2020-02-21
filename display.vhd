library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
  Port (Segments : out STD_LOGIC_VECTOR(6 downto 0);
    D: in STD_LOGIC_VECTOR(3 downto 0));
end display;

architecture Behavioral of display is

begin
Process(D)
begin
    case D is
        when "0000" => Segments<="0000001";
        when "0001" => Segments<="1001111";
        when "0010" => Segments<="0010010";
        when "0011" => Segments<="0000110";
        when "0100" => Segments<="1001100";
        when "0101" => Segments<="0100100";
        when "0110" => Segments<="0100000";
        when "0111" => Segments<="0001111";
        when "1000" => Segments<="0000000";
        when "1001" => Segments<="0000100";
        when "1010" => Segments<="0001000";
        when "1011" => Segments<="1100000";
        when "1100" => Segments<="0110001";
        when "1101" => Segments<="1000010";
        when "1110" => Segments<="0110000";
        when "1111" => Segments<="0111000";
        when others => NULL;
    end case;
end process;

end Behavioral;
