library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tb_Counter is
end tb_Counter;

architecture tb of tb_Counter is

    component Counter is
        port
        (
            count : out std_logic_vector(3 downto 0);
            clk   : in  std_logic;
            reset : in  std_logic
        );
    end component;

    signal count : std_logic_vector(3 downto 0) := (others => '0');
    signal clk   : std_logic                    := '0';
    signal reset : std_logic                    := '0';

begin
    clk_stimulus : process
    begin
        clk <= clk xor '1';
        wait for 50 ps;
    end process;

    uut : Counter port map
        (count, clk, reset);

    data_stimulus : process
    begin
        reset <= '1';
        wait for 200 ps;
        reset <= '0';
        wait for 2700 ps;

        assert false report "Test: OK" severity failure;
    end process;
end tb;