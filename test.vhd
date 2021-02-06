LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Button_debouncer IS
    PORT
    (
        input  : IN     STD_LOGIC;
        clk    : IN     STD_LOGIC;
        output : BUFFER STD_LOGIC := '0'
    );
END Button_debouncer;

ARCHITECTURE Behavioral OF Button_debouncer IS
BEGIN
    PROCESS (input, clk)
        VARIABLE counter : INTEGER RANGE 0 TO 50000000 := 0;
        VARIABLE pressed : BOOLEAN;
    BEGIN
        IF rising_edge(clk) THEN
            IF input = '1' THEN
                pressed := true;
            ELSE
                output <= '0';
            END IF;
            IF pressed = true THEN
                counter := counter + 1;
                IF counter = 2500000 THEN
                    counter := 0;
                    pressed := false;
                    IF input = '1' THEN
                        output <= '1';
                    ELSE
                        output <= '0';
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;