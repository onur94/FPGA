library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tb_Divider is
end tb_Divider;

architecture tb of tb_Divider is

    component Divider is                                        
		port
		(
			S, CLK, RESET  : in std_logic;
			Input1, Input2 : in std_logic_vector (7 downto 0);                                   
			Quotient, Remainder : out std_logic_vector(7 downto 0)
		);     
	end component;

    signal S : std_logic := '0';
    signal CLK   : std_logic := '0';
    signal RESET : std_logic := '0';
    signal Input1 : std_logic_vector (7 downto 0);    
    signal Input2 : std_logic_vector (7 downto 0);    
    signal Quotient : std_logic_vector (7 downto 0);    
    signal Remainder : std_logic_vector (7 downto 0);    

begin
    clk_stimulus : process
    begin
        CLK <= CLK xor '1';
        wait for 5 ns;
    end process;

    uut : Divider port map
        (S, CLK, RESET, Input1, Input2, Quotient, Remainder);

    data_stimulus : process
    begin
		S <= '0';
        reset <= '0';
        wait for 30 ns; -- 3 clock cycle
        
        reset <= '1';
        wait for 30 ns; -- 3 clock cycle
        
        
        Input1 <= "01000000"; -- 64
        Input2 <= "00000101"; -- 5
        wait for 20 ns; -- 2 clock cycle
        
        S <= '1';
        wait for 20 ns; -- 2 clock cycle
        
        S <= '0';
        wait for 500 ns; -- 50 clock cycle
        
        
        Input1 <= "01000001"; -- 65
        Input2 <= "00001001"; -- 9
        wait for 20 ns; -- 2 clock cycle
        
        S <= '1';
        wait for 20 ns; -- 2 clock cycle
        
        S <= '0';
        wait for 500 ns; -- 50 clock cycle
        
        
        Input1 <= "01011010"; -- 90
        Input2 <= "00011110"; -- 30
        wait for 20 ns; -- 2 clock cycle
        
        S <= '1';
        wait for 20 ns; -- 2 clock cycle
        
        S <= '0';
        wait for 500 ns; -- 50 clock cycle
        
        
        Input1 <= "00001111"; -- 15
        Input2 <= "00010100"; -- 20
        wait for 20 ns; -- 2 clock cycle
        
        S <= '1';
        wait for 20 ns; -- 2 clock cycle
        
        S <= '0';
        wait for 500 ns; -- 50 clock cycle

        assert false report "Test: OK" severity failure;
    end process;
end tb;