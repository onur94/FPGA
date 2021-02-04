library IEEE;
use IEEE.STD_LOGIC_1164.ALL;                

entity Button_debouncer is                                        
    port
    (
        input   : in std_logic;
        clk     : in std_logic;                                   
        output  : buffer std_logic := '0'
    );     
end Button_debouncer;

architecture Behavioral of Button_debouncer is                                     
begin                                                                  
    process (input, clk)    												
        variable counter : integer range 0 to 50000000 := 0;
        variable pressed : boolean;
    begin 
        if rising_edge(clk) then
            if input = '1' then
                pressed := true;
            else
                output <= '0';
            end if;	
            if pressed = true then
                counter := counter + 1;
                if counter = 2500000 then
                    counter := 0;
                    pressed := false;
                    if input = '1' then
                        output <= '1';
                    else
                        output <= '0';
                    end if;
                end if; 
            end if;
        end if;
    end process;                           
end Behavioral;