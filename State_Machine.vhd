library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity State_Machine is
    port
    (
        clk : in  std_logic;
        rst : in  std_logic;
        led : out std_logic_vector (2 downto 0) := (others => '0')
    );
end State_Machine;

architecture Behavioral of State_Machine is
    type my_states is (IDLE, State_1, State_2);
    signal state  : my_states;

    signal output : std_logic_vector (2 downto 0) := (others => '0');
begin
    led <= output;

    process (clk)
    begin
        if rst = '1' then
            state  <= IDLE;
            output <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    output <= "001";
                    state  <= State_1;
                    
                when State_1 =>
                    output <= "010";
                    state  <= State_2;
                    
                when State_2 =>
                    output <= "100";
                    state  <= IDLE;
                    
                when others =>
                    output <= "000";
                    state  <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;