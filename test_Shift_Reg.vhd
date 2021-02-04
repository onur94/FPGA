library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity test_Shift_Reg is
end;

architecture test of test_Shift_Reg is

component Shift_Reg
    port 
    (
        a       : out std_logic;
        b       : out std_logic;
        c       : out std_logic;
        d       : out std_logic;
        data_in : in std_logic;
        reset   : in std_logic;
        clk     : in std_logic
    );
end component;

signal data_in : std_logic := '0';
signal reset : std_logic := '0';
signal clk : std_logic := '1';
signal a, b, c, d: std_logic;

begin

    dev_to_test:  shift_reg 
        port map(a, b, c, d, data_in, reset, clk); 

    clk_stimulus:  process
    begin
        wait for 50 ps;
        clk <= not clk;
    end process clk_stimulus;

    data_stimulus:  process
    begin
        wait for 200 ps;
        data_in <= not data_in;
        wait for 400 ps;
    end process data_stimulus;

end test;
