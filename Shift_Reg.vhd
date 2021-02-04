library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
                   
entity Shift_Reg is
	port
	(
		clk 	: in std_logic; 
		data_in	: in std_logic;
		reset	: in std_logic;
		a 	: out std_logic;
		b 	: out std_logic;
		c	: out std_logic;
		d 	: out std_logic
	);     
end Shift_Reg;

architecture Behavioral of Shift_Reg is
	signal a_reg, b_reg, c_reg, d_reg : std_logic := '0';
begin
	a <= a_reg;
	b <= b_reg;
	c <= c_reg;
	d <= d_reg;
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				a_reg <= '0';
				b_reg <= '0';
				c_reg <= '0';
				d_reg <= '0';
			else
				a_reg <= data_in;
				b_reg <= a_reg;
				c_reg <= b_reg;
				d_reg <= c_reg;
			end if;
		end if;
	end process;
end Behavioral;
