library IEEE;
use IEEE.STD_LOGIC_1164.ALL;                   
use IEEE.std_logic_signed.all; 
use ieee.numeric_std.all;

entity Divider is                                        
    port
    (
        S, CLK, RESET  : in std_logic;
        Input1, Input2 : in std_logic_vector (7 downto 0);                                   
        Quotient, Remainder : out std_logic_vector(7 downto 0)
    );     
end Divider;

architecture BEHAVIOR of Divider is     
	type my_states is (T0, T1, T2, T3);
    signal state : my_states;
    
	signal A : std_logic_vector (7 downto 0); 
	signal B : std_logic_vector (7 downto 0); 
	signal C : std_logic_vector (7 downto 0); 
	signal R : std_logic_vector (7 downto 0); 
	signal Q : std_logic_vector (7 downto 0); 
begin      
	process (RESET, CLK)  
	begin
		if RESET = '0' then
			A <= (others => '0');
			B <= (others => '0');
			C <= (others => '0');
			R <= (others => '0');
			Q <= (others => '0');
			Quotient <= (others => '0');
			Remainder <= (others => '0');
			state <= T0;
		elsif rising_edge(clk) then
			case state is
				when T0 => -- T0 Block
					if S = '1' then
						A <= Input1;
						B <= Input2;
						C <= "00001000";
						R <= (others => '0');
						Q <= (others => '0');
						state <= T1;
					else
						state <= T0;
					end if;
					
				when T1 => -- T1 Block
					R <= R(6 downto 0) & A(7);
					A <= A(6 downto 0) & '0';
					state <= T2;
					
				when T2 => -- T2 Block
					C <= C - 1;
					if R >= B then
						Q <= Q(6 downto 0) & '1';
						R <= R - B;
					else
						Q <= Q(6 downto 0) & '0';
					end if;
					state <= T3;
					
				when T3 => -- T3 Block
					if C = x"00" then
						Quotient <= Q;
						Remainder <= R;
						state <= T0;
					else
						state <= T1;
					end if;
			end case;
		end if;
	end process;
end BEHAVIOR;