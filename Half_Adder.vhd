library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Half_Adder is
	port 
	(
		a 		: in std_logic;
		b 		: in std_logic;
		sum 	: out std_logic;
		carry : out std_logic
	);
end Half_Adder;

architecture Behavioral of Half_Adder is
begin
	sum <= a xor b;
	carry <= a and b;
end Behavioral;