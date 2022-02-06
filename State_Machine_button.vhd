library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity State_Machine_button is
    port
    (
        button : in  std_logic;
        clk    : in  std_logic;
        rst    : in  std_logic;
        led    : out std_logic_vector (2 downto 0)
    );
end State_Machine_button;
architecture Behavioral of State_Machine_button is
    type my_states is (IDLE, BUTTON_PRESSED, BUTTON_WAIT);
    signal state : my_states;

    signal output : std_logic_vector (2 downto 0) := (others => '0');
begin
    led <= output;

    process (clk)
    begin
        if rst = '1' then
            state <= IDLE;
            output <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    output <= "000";
                    if button = '1' then
                        state <= BUTTON_PRESSED;
                    else
                        state <= IDLE;
                    end if;

                when BUTTON_PRESSED =>
                    output <= "111";
                    state <= BUTTON_WAIT;

                when BUTTON_WAIT =>
                    output <= "000";
                    if button = '1' then
                        state <= BUTTON_WAIT;
                    else
                        state <= IDLE;
                    end if;

                when others =>
                    output <= (others => 'Z');
                    --state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;