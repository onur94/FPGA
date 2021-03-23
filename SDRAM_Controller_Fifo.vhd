library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity SDRAM_Controller_Fifo is
    port
    (
        PLLClock         : in    std_logic;
        PLLLocked        : in    std_logic;
        RAMCLK, CKE      : out   std_logic;
        CS, RAS, CAS, WE : out   std_logic;
        DQMH, DQML       : out   std_logic;
        BA               : out   std_logic_vector(1 downto 0);
        ADDRESS          : out   std_logic_vector(11 downto 0);
        DATA             : inout std_logic_vector(15 downto 0);
        DATA_Output      : out   std_logic_vector(15 downto 0);
        write_enable     : in    std_logic;
        read_enable      : in    std_logic;
        write_a_data     : in    std_logic);
end SDRAM_Controller_Fifo;

architecture Behavioral of SDRAM_Controller_Fifo is

    component SDRAM_Controller
        port
        (
            Clk, Enable      : in    std_logic;
            RAMCLK, CKE      : out   std_logic;
            CS, RAS, CAS, WE : out   std_logic;
            DQMH, DQML       : out   std_logic;
            BA               : out   std_logic_vector(1 downto 0);
            ADDRESS          : out   std_logic_vector(11 downto 0);
            DATA             : inout std_logic_vector(15 downto 0);

            port_ADDRESS : in std_logic_vector(22 downto 0);
            port_DATAIN : in std_logic_vector(15 downto 0);
            port_DATAOUT : out std_logic_vector(15 downto 0);
            port_RW, port_ENABLE : in std_logic;
            port_BURST : in std_logic_vector(2 downto 0);
            port_BUSY, port_READY : out std_logic);
    end component;

    signal port_ADDRESS : std_logic_vector(22 downto 0) := (others => '0');
    signal port_DATAIN : std_logic_vector(15 downto 0) := (others => '0');
    signal port_RW, port_ENABLE : std_logic;
    signal port_BUSY, port_READY : std_logic;
    signal port_BURST : std_logic_vector(2 downto 0);

    signal port_DATAOUT : std_logic_vector(15 downto 0);

    type states is (write_sdram, read_sdram);
    signal sdram_state : states;

    signal sdram_ready : std_logic := '0';

begin

    Controller : SDRAM_Controller
    port map
    (
        PLLClock, PLLLocked,
        RAMCLK, CKE,
        CS, RAS, CAS, WE,
        DQMH, DQML,
        BA, ADDRESS,
        DATA,
        port_ADDRESS,
        port_DATAIN,
        port_DATAOUT,
        port_RW, port_ENABLE,
        port_BURST,
        port_BUSY, port_READY);

    process (PLLClock, port
        _BUSY)
        variable state : integer range 0 to 10001 := 0;
        variable write_active : std_logic := '1';
        variable counter : integer range 0 to 20_000_000;
    begin
        if rising_edge(PLLClock) then
            if counter < 20_000_000 then
                counter := counter + 1;
            else
                sdram_ready <= '1';
            end if;
            if sdram_ready = '1' then
                if port_BUSY = '0' and PLLLocked = '1' then
                case sdram_state is
                    when write_sdram =>
                        if write_enable = '0' then
                            if state < 3 then
                                port_ADDRESS <= std_logic_vector(to_unsigned(1024 + state, 23));
                                port_DATAIN <= std_logic_vector(to_unsigned(state + 3000, 16));
                                port_RW <= '0';
                                port_ENABLE <= '1';
                                state := State + 1;
                            elsif state < 6 then
                                port_ADDRESS <= std_logic_vector(to_unsigned(2097152 + state - 3, 23));
                                port_DATAIN <= std_logic_vector(to_unsigned(state + 19000, 16));
                                port_RW <= '0';
                                port_ENABLE <= '1';
                                state := State + 1;
                            elsif state < 9 then
                                port_ADDRESS <= std_logic_vector(to_unsigned(2048 + state - 6, 23));
                                port_DATAIN <= std_logic_vector(to_unsigned(state + 12000, 16));
                                port_RW <= '0';
                                port_ENABLE <= '1';
                                state := State + 1;
                            elsif state < 12 then
                                port_ADDRESS <= std_logic_vector(to_unsigned(8192 + state - 9, 23));
                                port_DATAIN <= std_logic_vector(to_unsigned(state + 6800, 16));
                                port_RW <= '0';
                                port_ENABLE <= '1';
                                state := State + 1;
                            elsif state < 15 then
                                port_ADDRESS <= std_logic_vector(to_unsigned(16384 + state - 12, 23));
                                port_DATAIN <= std_logic_vector(to_unsigned(state + 1800, 16));
                                port_RW <= '0';
                                port_ENABLE <= '1';
                                state := State + 1;
                            elsif state < 18 then
                                port_ADDRESS <= std_logic_vector(to_unsigned(32768 + state - 15, 23));
                                port_DATAIN <= std_logic_vector(to_unsigned(state + 5862, 16));
                                port_RW <= '0';
                                port_ENABLE <= '1';
                                state := State + 1;
                            else
                                sdram_state <= read_sdram;
                                state := 0;
                            end if;
                        end if;
                    when read_sdram =>
                        if read_enable = '1' then
                            if fifo_full = '0' then
                                if state < 3 then
                                    port_ADDRESS <= std_logic_vector(to_unsigned(2048 + state, 23));
                                    port_RW <= '1';
                                    port_ENABLE <= '1';
                                    port_BURST <= "000";
                                    state := State + 1;
                                elsif state < 6 then
                                    port_ADDRESS <= std_logic_vector(to_unsigned(2097152 + state - 3, 23));
                                    port_RW <= '1';
                                    port_ENABLE <= '1';
                                    port_BURST <= "000";
                                    state := State + 1;
                                elsif state < 9 then
                                    port_ADDRESS <= std_logic_vector(to_unsigned(16384 + state - 6, 23));
                                    port_RW <= '1';
                                    port_ENABLE <= '1';
                                    port_BURST <= "000";
                                    state := State + 1;
                                elsif state < 12 then
                                    port_ADDRESS <= std_logic_vector(to_unsigned(8192 + state - 9, 23));
                                    port_RW <= '1';
                                    port_ENABLE <= '1';
                                    port_BURST <= "000";
                                    state := State + 1;
                                elsif state < 15 then
                                    port_ADDRESS <= std_logic_vector(to_unsigned(32768 + state - 12, 23));
                                    port_RW <= '1';
                                    port_ENABLE <= '1';
                                    port_BURST <= "000";
                                    state := State + 1;
                                elsif state < 18 then
                                    port_ADDRESS <= std_logic_vector(to_unsigned(1024 + state - 15, 23));
                                    port_RW <= '1';
                                    port_ENABLE <= '1';
                                    port_BURST <= "000";
                                    state := State + 1;
                                else
                                    port_ENABLE <= '0';
                                end if;
                            else
                                port_ENABLE <= '0';
                            end if;
                        end if;
                end case;
            else
                port_ENABLE <= '0';
            end if;

            if port_READY = '1' then
                DATA_Output <= DATA;
            end if;
        end if;
    end process;
end Behavioral;