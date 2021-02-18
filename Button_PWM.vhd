library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Button_PWM is
    port
    (
        button : in  std_logic;
        rst    : in  std_logic;
        duty   : out std_logic_vector (7 downto 0) -- 255
    );
end Button_PWM;

architecture Behavioral of Button_PWM is
    type my_states is (Level_1, Level_2, Level_3, Level_4, Level_5, Level_6);
    signal state : my_states;

    signal output : std_logic_vector (7 downto 0) := (others => '0');
begin
    duty <= output;

    process (button, rst)
    begin
        if rst = '1' then
            state <= Level_1;
            output <= (others => '0');
        elsif rising_edge(button) then
            case state is
                when Level_1 =>
                    output <= std_logic_vector(to_unsigned(51, 8));
                    state <= Level_2;

                when Level_2 =>
                    output <= std_logic_vector(to_unsigned(102, 8));
                    state <= Level_3;

                when Level_3 =>
                    output <= std_logic_vector(to_unsigned(153, 8));
                    state <= Level_4;

                when Level_4 =>
                    output <= std_logic_vector(to_unsigned(204, 8));
                    state <= Level_5;

                when Level_5 =>
                    output <= std_logic_vector(to_unsigned(255, 8));
                    state <= Level_6;

                when Level_6 =>
                    output <= std_logic_vector(to_unsigned(0, 8));
                    state <= Level_1;

                when others =>
                    output <= (others => 'Z');
                    state <= Level_1;
            end case;
        end if;
    end process;
end Behavioral;