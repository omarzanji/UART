library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode is
 Port (
 dIn: in STD_LOGIC_VECTOR(7 downto 0);
 errorLEDS: out STD_LOGIC_VECTOR(1 downto 0);
 dataOut: out STD_LOGIC_VECTOR(3 downto 0));
end decode;

architecture Behavioral of decode is
signal P: STD_LOGIC_VECTOR(3 downto 0);
signal error: STD_LOGIC_VECTOR(1 downto 0);
begin

--d0 d1 d2 d3 d4 d5 d6 d7
--d7 d6 d5 d4 d3 d2 d1 d0

-- p0 p1 p2 p3
-- p3 p2 p1 p0

P(3) <= dIn(5) XOR dIn(3) XOR dIn(1);
P(2) <= dIn(5) XOR dIn(2) XOR dIn(1);
P(1) <= dIn(3) XOR dIn(2) XOR dIn(1);
P(0) <= dIn(7) XOR dIn(6) XOR dIn(5) XOR dIn(4) XOR dIn(3) XOR dIn(2) XOR dIn(1);
error(1) <= dIn(7) XOR dIn(6) XOR dIn(5) XOR dIn(4) XOR dIn(3) XOR dIn(2) XOR dIn(1) XOR dIn(0);
error(0) <= ((P(3) XOR dIN(7)) OR (P(2) XOR dIn(6)) OR (P(1) XOR dIn(4)) OR (P(0) XOR dIn(0))) AND NOT error(1);

dataOut(3) <= (NOT ((P(3) XOR dIn(7)) AND (P(2) XOR dIn(6)) AND (NOT (P(1) XOR dIn(4)))) AND dIn(5)) OR (NOT dIn(5) AND ((P(3) XOR dIn(7)) AND NOT (P(1) XOR dIn(4))));
dataOut(2) <= (NOT ((P(3) XOR dIn(7)) AND (P(1) XOR dIn(4)) AND (NOT (P(2) XOR dIn(6)))) AND dIn(3)) OR (NOT dIn(3) AND ((P(3) XOR dIn(7)) AND NOT (P(2) XOR dIn(6))));
dataOut(1) <= (NOT ((P(1) XOR dIn(4)) AND (P(2) XOR dIn(6)) AND (NOT (P(3) XOR dIn(7)))) AND dIn(2)) OR (NOT dIn(2) AND ((P(2) XOR dIn(6)) AND NOT (P(3) XOR dIn(7))));
dataOut(0) <= (NOT ((P(3) XOR dIn(7)) AND (P(2) XOR dIn(6)) AND (P(1) XOR dIn(4))) AND dIn(1)) OR (NOT dIn(1) AND ((P(3) XOR dIn(7)) AND (P(1) XOR dIn(4))));

errorLEDS <= error;
end Behavioral;
