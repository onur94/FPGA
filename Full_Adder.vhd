library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Full_Adder is
	port 
	(
		a 			: in std_logic;
		b 			: in std_logic;
		carry_in 	: in std_logic;
		carry_out 	: out std_logic;
		sum 		: out std_logic
	);
end Full_Adder;

architecture Behavioral of Full_Adder is
begin
	sum <= a XOR b XOR carry_in;
	carry_out <= (a AND b) OR ((a XOR b) AND carry_in);
end Behavioral;