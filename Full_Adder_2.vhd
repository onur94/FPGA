library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Full_Adder_2 is
	port 
	(
		a 			: in std_logic;
		b 			: in std_logic;
		carry_in 	: in std_logic;
		carry_out 	: out std_logic;
		sum 		: out std_logic
	);
end Full_Adder_2;

architecture Behavioral of Full_Adder_2 is
	signal inputs : std_logic_vector (2 downto 0);
	signal outputs : std_logic_vector (1 downto 0);
begin
	inputs <= a & b & carry_in;
	carry_out <= outputs(1);
	sum <= outputs(0);
	process(inputs)
	begin
		case inputs is
			when "000" =>
				outputs <= "00";
			when "001" =>
				outputs <= "01";
			when "010" =>
				outputs <= "01";
			when "011" =>
				outputs <= "10";
			when "100" =>
				outputs <= "01";
			when "101" =>
				outputs <= "10";
			when "110" =>
				outputs <= "10";
			when "111" =>
				outputs <= "11";
			when others =>
				outputs <= (others => 'X');
		end case;
	end process;
end Behavioral;