library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity MAX7219 is
    generic 
    (
        sys_clk_freq : integer := 50_000_000;
        spi_clk_freq : integer := 1_000_000
    );
    port
    (
        clk  : in  std_logic;
        rst  : in  std_logic;
        cs   : out std_logic;
        sclk : out std_logic;
        mosi : out std_logic;
        miso : in  std_logic
    );
end MAX7219;

architecture Behavioral of MAX7219 is

    type states is (wait_1ms, start, finish);
    signal state : states;

    signal enable : std_logic;
    signal miso_data : std_logic_vector (7 downto 0);
    signal mosi_data : std_logic_vector (7 downto 0);
    signal data_ready : std_logic;
    
    component SPI_Master is
		generic 
		(
			c_clkfreq 		: integer;
			c_sclkfreq 		: integer;
			c_cpol			: std_logic := '0';
			c_cpha			: std_logic := '0'
		);
		port 
		( 
			clk_i 			: in  STD_LOGIC;
			en_i 			: in  STD_LOGIC;
			mosi_data_i 	: in  STD_LOGIC_VECTOR (7 downto 0);
			miso_data_o 	: out STD_LOGIC_VECTOR (7 downto 0);
			data_ready_o 	: out STD_LOGIC;
			cs_o 			: out STD_LOGIC;
			sclk_o 			: out STD_LOGIC;
			mosi_o 			: out STD_LOGIC;
			miso_i 			: in  STD_LOGIC
		);
	end component;

    type data_states is array (0 to 39) of std_logic_vector (7 downto 0);
    signal spi_data : data_states := (x"0B", x"07", --Scan all digits
                                      x"09", x"00", --No decode mode
                                      x"01", x"00", --Clear all digits
                                      x"02", x"00", 
                                      x"03", x"00", 
                                      x"04", x"00", 
                                      x"05", x"00", 
                                      x"06", x"00", 
                                      x"07", x"00", 
                                      x"08", x"00", 
                                      x"0C", x"01", --Shutdown disable
                                      x"0A", x"FF", --Intesy Max
                                      x"08", x"30", --Digit 8 -> 1
                                      x"07", x"6D", --Digit 7 -> 2
                                      x"06", x"79", --Digit 6 -> 3
                                      x"05", x"33", --Digit 5 -> 4
                                      x"04", x"5B", --Digit 4 -> 5
                                      x"03", x"5F", --Digit 3 -> 6
                                      x"02", x"70", --Digit 2 -> 7
                                      x"01", x"7F"  --Digit 1 -> 8
                                     );
                                     
begin

    --instantiate the SPI Master
    SPI_Master_0 : SPI_Master
    generic map(c_clkfreq => sys_clk_freq, c_sclkfreq => spi_clk_freq, c_cpol => '0', c_cpha => '0')
    port map(clk_i => clk, en_i => enable, mosi_data_i => mosi_data, miso_data_o => miso_data,
             data_ready_o => data_ready, cs_o => cs, sclk_o => sclk, mosi_o => mosi, miso_i => miso);

    process (clk)
        variable counter : integer range 0 to sys_clk_freq := 0;
        variable state_counter : integer range 0 to data_states'LENGTH := 0;
    begin
        if rst = '1' then
            enable <= '0';
            counter := 0;
            state_counter := 0;
            mosi_data <= (others => '0');
            state <= wait_1ms;

            elsif rising_edge(clk) then
            case state is
                when wait_1ms =>
                    if (counter < sys_clk_freq/1000) then
                        counter := counter + 1;
                    else
                        counter := 0;
                        state <= start;
                    end if;

                when start =>
                    enable <= '1';
                    mosi_data <= spi_data(state_counter);
                    if data_ready = '1' then
                        state_counter := state_counter + 1;
                        mosi_data <= spi_data(state_counter);
                        state <= finish;
                    end if;

                when finish =>
                    if data_ready = '1' then
                        enable <= '0';
                        state_counter := state_counter + 1;
                        if state_counter < data_states'LENGTH then
                            state <= wait_1ms;
                        end if;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;