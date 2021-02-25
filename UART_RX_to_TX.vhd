library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_RX_to_TX is
    port
    (
        rst        : in  std_logic;
        clk        : in  std_logic;
        rx_data    : in  std_logic_vector(7 downto 0);
		rx_valid   : in  std_logic := '0';
        tx_valid   : out std_logic := '0';
        tx_busy    : in  std_logic;
        tx_data    : out std_logic_vector(7 downto 0)
    );
end UART_RX_to_TX;

architecture Behavioral of UART_RX_to_TX is
    type machine is(read_data, active_uart, deactive_uart);
    signal state : machine;
    signal output_reg : std_logic_vector(7 downto 0) := (others => '0');
	
begin
    tx_data <= output_reg;

    process (clk)
    begin
        if rst = '1' then
            output_reg <= (others => '0');
            tx_valid <= '0';
            state <= read_data;
        elsif rising_edge(clk) then
            case state is
                when read_data =>
                    if rx_valid = '1' then
                        output_reg <= rx_data;
                        state <= active_uart;
                    end if;
                when active_uart =>
                    if (tx_busy = '0') then
						tx_valid <= '1';
                        state <= deactive_uart;
                    else
                        state <= active_uart;
                    end if;
                when deactive_uart =>
                    tx_valid <= '0';
                    state <= read_data;
            end case;
        end if;
    end process;
end Behavioral;