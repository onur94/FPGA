library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity UART_Top is
    port
    (
        tx_done : in  std_logic;
        clk     : in  std_logic;
        data    : out std_logic_vector (7 downto 0) := (others => '0');
        enable  : out std_logic                     := '0'
    );
end UART_Top;

architecture Behavioral of UART_Top is
    type my_states is (State_0, State_1, State_2, State_3, State_4, State_5);
    signal state : my_states;

begin
    process (clk)
        variable count : integer range 0 to 100000000 := 0;
    begin
        if rising_edge(clk) then
            if count /= 100000000 then
                count := count + 1;
            elsif count = 100000000 then
                case state is
                    when State_0 =>
                        enable <= '1';
                        data <= x"41";
                        state <= State_1;
                    when state_1 =>
                        enable <= '0';
                    when state_2 =>
                        enable <= '1';
                        data <= x"42";
                        state <= State_3;
                    when state_3 =>
                        enable <= '0';
                    when state_4 =>
                        enable <= '1';
                        data <= x"43";
                        state <= State_5;
                    when state_5 =>
                        enable <= '0';
                    when others =>
                        enable <= '0';
                        state <= State_0;
                end case;
            end if;
            if tx_done = '1' then
                if state = state_1 then
                    state <= state_2;
                elsif state = state_3 then
                    state <= state_4;
                end if;
            end if;
        end if;
    end process;
end Behavioral;