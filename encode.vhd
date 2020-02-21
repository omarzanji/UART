library ieee;
use ieee.std_logic_1164.all;

entity encode is
    Port (
        Din : in std_logic_vector (3 downto 0);
        Dout : out std_logic_vector (7 downto 0));
end encode;

architecture Behavioral of encode is

    signal p : std_logic_vector (3 downto 0);

begin

    -- d1,d2,d3,d4
    -- d4,d3,d2,d1

    p(3) <= Din(3) XOR Din(2) XOR Din(0);
    p(2) <= Din(3) XOR Din(1) XOR Din(0);
    p(1) <= Din(2) XOR Din(1) XOR Din(0);
    p(0) <= p(3) XOR p(2) XOR p(1) XOR Din(3) XOR Din(2) XOR Din(1) XOR Din(0);

    Dout(7) <= p(3);
    Dout(6) <= p(2);
    Dout(5) <= Din(3);
    Dout(4) <= p(1);
    Dout(3) <= Din(2);
    Dout(2) <= Din(1);
    Dout(1) <= Din(0);
    Dout(0) <= p(0);

end architecture;
