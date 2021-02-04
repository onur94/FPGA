library IEEE;
use IEEE.STD_LOGIC_1164.ALL;                    

entity Button_counter is                                        
	port
	(
		button 	: in std_logic;                                 
		led 		: buffer STD_LOGIC := '0'
	);     
end Button_counter;
                                              
architecture Behavioral of Button_counter is                                     
	signal counter : integer range 0 to 5 := 0;
begin                                                                  
	process (button)    												
	begin 
		if rising_edge(button) then
			counter <= counter + 1;
				if counter = 4 then                           
					led <= led XOR '1';
					counter <= 0;
				end if; 
		end if;	
	end process;                           
end Behavioral;