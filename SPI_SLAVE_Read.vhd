library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SPI_SLAVE_Read is
    port
    (
        clk     : in  std_logic;
        rst     : in  std_logic;
        data_in : in  std_logic_vector (7 downto 0);
        led     : out std_logic
    );
end SPI_SLAVE_Read;

architecture Behavioral of SPI_SLAVE_Read is
    signal reg_led : std_logic := '0';
begin
    led <= reg_led;
    process (clk)
    begin
        if rst = '1' then
            reg_led <= '0';
        elsif rising_edge(clk) then
            if data_in = x"23" then
                reg_led <= '1';
            elsif data_in = x"34" then
                reg_led <= '0';
            elsif data_in = x"45" then
                reg_led <= '1';
            elsif data_in = x"67" then
                reg_led <= '0';
            elsif data_in = x"78" then
                reg_led <= '1';
            elsif data_in = x"89" then
                reg_led <= '0';
            end if;
        end if;
    end process;
end Behavioral;