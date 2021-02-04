library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Led_vector is
    port ( 
        clock : in std_logic;
        led   : out STD_LOGIC_VECTOR(2 downto 0) -- 3 bit vector
    );
end Led_vector;

architecture Behavioral of Led_vector is
    signal counter : integer range 0 to 5;  -- 0 1 2 3 4 5
begin
    process(clock)
        variable no : integer range 0 to 4; -- 0 1 2 3 4
    begin
        if clock = '1' then
            counter <= counter + 1;
            if counter = 4 then
                no := no + 1;
                if no = 4 then
                    no := 0;
                end if;
                counter <= 0;
            end if;
            case no is
                when 0 => led <= "111";
                when 1 => led <= "011";
                when 2 => led <= "101";
                when 3 => led <= "110";
                when others =>  led <= "111";
            end case;
        end if;
    end process;
end Behavioral;
