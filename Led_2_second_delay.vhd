library IEEE;
use IEEE.STD_LOGIC_1164.ALL;                   
                   
entity Led_2_second_delay IS                                        
	port
	(
		clk : in std_logic;                                   
		led : out std_logic := '1'
	);     
end Led_2_second_delay;
                                              
architecture Behavioral of Led_2_second_delay IS                                     
begin                                                                  
	process (clk)    												
		variable count : integer range 0 to 50000000 := 0;
		variable state : integer range 0 to 3 := 0;
	begin       		
		if rising_edge(clk) then
			count := count + 1;
			if count = 50000000 then                           
				state := state  + 1;
				count := 0;
				if state = 2 then
					led <= '0';
				elsif state = 3 then
					led <= '1';
					state := 0;
				end if;
			end if;                                                      
		end if; 
	end process;                           
end Behavioral;