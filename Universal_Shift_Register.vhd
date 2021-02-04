library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Universal_Shift_Register is
	generic (
		data_width	: integer := 8);
	Port (
		A     : out std_logic_vector(data_width - 1 downto 0);
		I 	  : in std_logic_vector(data_width - 1 downto 0);
		S 	  : in std_logic_vector(1 downto 0);
		reset : in std_logic;
		clk   : in std_logic);
end Universal_Shift_Register;

architecture Behavioral of Universal_Shift_Register is
	signal A_reg	: std_logic_vector(data_width - 1 downto 0) ;
begin
	A <= A_reg;
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				A_reg <= (others => '0');
			else
				case S is
					when "00" => -- Hold
						A_reg <= A_reg;
						
					when "01" => -- Right shift
						A_reg(data_width - 2 downto 0) <= A_reg(data_width - 1 downto 1);
						A_reg(data_width - 1) <= '0';
						
					when "10" => -- Left shift
						A_reg(data_width - 1 downto 1) <= A_reg(data_width - 2 downto 0);
						A_reg(0) <= '0';
						
					when "11" => -- Parallel load
						A_reg <= I;
						
					when others =>
						A_reg <= (others => 'X');
				end case;
			end if;
		end if;
	end process;
end Behavioral;