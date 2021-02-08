library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity Counter is
    port
    (
        count : out std_logic_vector(3 downto 0) := (others => '0');
        clk   : in  std_logic;
        reset : in  std_logic
    );
end Counter;

architecture Behavioral of Counter is
    signal counter      : unsigned(3 downto 0) := (others => '0');
    signal counter_2    : unsigned(3 downto 0) := (others => '0');
    constant maxcount   : integer              := 4;
    constant maxcount_2 : integer              := 5;
begin
    count <= std_logic_vector(counter_2);

    counter_proc : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or counter = maxcount then
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
    end process counter_proc;

    counter_proc_2 : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or counter_2 = maxcount_2 then
                counter_2 <= (others => '0');
            elsif counter = maxcount then
                counter_2 <= counter_2 + 1;
            end if;
        end if;
    end process counter_proc_2;
end Behavioral;