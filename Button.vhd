library IEEE;
use IEEE.STD_LOGIC_1164.ALL;                   

entity Button is                                        
    port
    (
        button 	: in std_logic;
        clk 	: in std_logic;                                   
        led 	: out std_logic := '0'
    );     
end Button;

architecture Behavioral of Button is                                     
begin                                                                  
    process (button, clk)    												
        variable count : integer range 0 to 50000000 := 0;
        variable state : std_logic := '1';
    begin 
        if button = '1' then
            if rising_edge(clk) then
                count := count + 1;
                if count = 25000000 then                           
                    state := state XOR '1';
                    count := 0;
                end if; 
            end if;
            led <= state;
        else
            count := 0;
            led <= '0';
        end if;	
    end process;                           
end Behavioral;