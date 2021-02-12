library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity tb_PWM is
end tb_PWM;

architecture tb of tb_PWM is
    component PWM is
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
            duty    : in  std_logic_vector(pwm_resolution - 1 downto 0);
            pwm_out : out std_logic
        );
    end component;
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal enable : std_logic := '1';
    signal duty : std_logic_vector(16 - 1 downto 0) := std_logic_vector(to_unsigned(12500, 16));
    signal pwm_out : std_logic;

begin
    clk_stimulus : process
    begin
        clk <= clk xor '1';
        wait for 1 ps;
    end process;

    uut : PWM port map
        (clk, rst, enable, duty, pwm_out);

    data_stimulus : process
    begin
        rst <= '0';
        wait for 400003 ps;

        assert false report "Test: OK" severity failure;
    end process;
end tb;