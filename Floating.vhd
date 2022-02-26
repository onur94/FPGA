library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.float_pkg.all;
use IEEE.numeric_std.all;

entity Floating is
    Generic (
        constant pi : real := 3.14
    );
    Port (
        clk : in std_logic;
        input_x : in integer
    );
end Floating;

architecture Behavioral of Floating is
    signal a : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal b : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal c : STD_LOGIC_VECTOR ( 31 downto 0 );
    --constant float_real : real := 1.2; -- Synthesizable
    --signal float_real : real;          -- Non-Synthesizable
begin
    process (clk)
    begin
        a <= to_slv(to_float(input_x)*pi);
        b <= to_slv(to_float(a)*2);
        c <= to_slv(to_float(b)+5.5);
    end process;
end Behavioral;