library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;

entity PWM is
    generic (
        clk_freq       : integer := 50000000;
        pwm_freq       : integer := 1000;
        pwm_resolution : integer := 16
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
    constant period : integer := clk_freq/pwm_freq;
    signal count : integer range 0 to period + 1 := 0;
    signal pwm_out_reg : std_logic := '0';

begin
    pwm_out <= pwm_out_reg;
    process (clk)
    begin
        if rst = '1' then
            count <= 0;
            pwm_out_reg <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                count <= count + 1;
                if count <= period - 1 then
                    if count <= duty - 1 then
                        pwm_out_reg <= '1';
                    elsif count >= duty - 1 then
                        pwm_out_reg <= '0';
                    end if;
                else
                    count <= 1;
                    pwm_out_reg <= '1';
                end if;
            else
                count <= 0;
                pwm_out_reg <= '0';
            end if;
        end if;
    end process;
end Behavioral;