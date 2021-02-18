library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PWM is
    generic 
	(
        clk_freq       : integer := 50_000_000;
        pwm_freq       : integer := 1000;
        pwm_resolution : integer := 8
    );
    port
    (
        clk     : in  std_logic;
        rst     : in  std_logic;
        enable  : in  std_logic;
        duty    : in  std_logic_vector(pwm_resolution - 1 downto 0); -- 65535
        pwm_out : out std_logic
    );
end PWM;

architecture Behavioral of PWM is
    constant period : integer := 2**pwm_resolution - 1;
	constant clk_divider : integer := clk_freq/pwm_freq/period/2;
	
    signal count : integer range 0 to period + 1 := 0;
    signal pwm_out_reg : std_logic := '0';
	
	signal divided_count : integer range 0 to clk_divider := 0;
	signal pwm_clock : std_logic := '0';

begin
	process (clk)
	begin
		if rising_edge(clk) then
			divided_count <= divided_count + 1;
			if divided_count = clk_divider then
				pwm_clock <= pwm_clock XOR '1';
				divided_count <= 0;
			end if;
		end if;
	end process;
	
    pwm_out <= pwm_out_reg;
	
	process (pwm_clock)
    begin
        if rst = '1' then
            count <= 0;
            pwm_out_reg <= '0';
        elsif rising_edge(pwm_clock) then
            if enable = '1' then
				if duty /= x"0" then
					count <= count + 1;
					if count < period then
						if count < duty then
							pwm_out_reg <= '1';
						elsif count >= duty then
							pwm_out_reg <= '0';
						end if;
					else
						count <= 1;
						pwm_out_reg <= '1';
					end if;
				else
					pwm_out_reg <= '0';
				end if;
            else
                count <= 0;
                pwm_out_reg <= '0';
            end if;
        end if;
    end process;
end Behavioral;