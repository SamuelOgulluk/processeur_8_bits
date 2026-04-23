-- Demi-additionneur (Half Adder)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Demi-Additionneur :
entity half_adder is
    Port (
        A : in STD_LOGIC;
        B : in STD_LOGIC;
        S : out STD_LOGIC;
        C : out STD_LOGIC
    );
end half_adder;

architecture rtl of half_adder is
begin
    S <= A xor B;
    C <= A and B;
end rtl;

-- Additionneur complet
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder is
    Port (
        A : in STD_LOGIC;
        B : in STD_LOGIC;
        Cin : in STD_LOGIC;
        S : out STD_LOGIC;
        Cout : out STD_LOGIC
    );
end full_adder;

architecture rtl of full_adder is
    signal S1, C1, C2 : STD_LOGIC;
begin
    HA1: entity work.half_adder port map(A => A, B => B, S => S1, C => C1);
    HA2: entity work.half_adder port map(A => S1, B => Cin, S => S, C => C2);
    Cout <= C1 or C2;
end rtl;
