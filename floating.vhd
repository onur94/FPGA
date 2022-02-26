library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.float_pkg.all;
use ieee.std_logic_arith.all;
use IEEE.numeric_std.all;

entity floating is
  Generic (
    constant adc_resolution : real := 0.000000298023223876953125
  );
  Port (
    clk : in std_logic;
    input_x : in integer;
    data_out : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
end floating;

architecture Behavioral of floating is
    signal float_slv : STD_LOGIC_VECTOR ( 31 downto 0 );
    --constant float_real : real := 1.2; -- Synthesizable
    --signal float_real : real;          -- Non-Synthesizable
begin
    process (clk)
    begin
        --x <= x * 2.0;
        float_slv <= to_slv(to_float(input_x)*adc_resolution);
        --float_real <= to_real(to_float(input_x))*adc_res;
    end process;
end Behavioral;
