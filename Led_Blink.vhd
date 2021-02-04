library IEEE;
use IEEE.STD_LOGIC_1164.ALL;                  

entity Led_Blink is                                        
    port
    (
        clk : in std_logic;                                   
        led : out std_logic := '0'
    );     
end Led_Blink;

architecture Behavioral of Led_Blink is                                     
begin                                                                  
    process (clk)    												
        count : integer range 0 to 50000000 := 0;
        variable state : std_logic := '0';
    begin       		
        if rising_edge(clk) then
            count := count + 1;
            if count = 50000000 then                           
                state := state XOR '1';
                count := 0;
            end if;                                                      
        end if;
        led <= state;
    end process;                           
end Behavioral;
