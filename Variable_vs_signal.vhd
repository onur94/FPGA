library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Variable_vs_signal is
    generic (
        sys_clk_freq : integer := 50_000_000
    );
    port
    (
        clk          : in  std_logic;
        clk_out      : out std_logic;
        rst          : in  std_logic;
        variable_out : out std_logic;
        signal_out   : out std_logic
    );
end Variable_vs_signal;

architecture Behavioral of Variable_vs_signal is
    constant max_counter : integer := sys_clk_freq/4;
    signal slow_clk : std_logic := '0';
    signal signal_counter : integer := 0;

begin
    clk_out <= slow_clk;
    process (clk)
        variable counter : integer range 0 to max_counter;
    begin
        if rst = '1' then
            counter := 0;
            slow_clk <= '0';
        elsif rising_edge(clk) then
            counter := counter + 1;
            if counter = max_counter then
                slow_clk <= not slow_clk;
                counter := 0;
            end if;
        end if;
    end process;

    process (slow_clk)
        variable variable_counter : integer := 0;
    begin
        if rst = '1' then
            signal_out <= '0';
            variable_out <= '0';
            signal_counter <= 0;
            variable_counter := 0;
        elsif rising_edge(slow_clk) then
            signal_counter <= signal_counter + 1;
            if signal_counter < 2 then
                signal_out <= '0';
            elsif signal_counter < 4 then
                signal_out <= '1';
            else
                signal_counter <= 0;
            end if;

            variable_counter := variable_counter + 1;
            if variable_counter < 2 then
                variable_out <= '0';
            elsif variable_counter < 4 then
                variable_out <= '1';
            else
                variable_counter := 0;
            end if;
        end if;
    end process;
end Behavioral;