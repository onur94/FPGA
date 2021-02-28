library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SPI_Master_Send is
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
end SPI_Master_Send;

architecture Behavioral of SPI_Master_Send is

    type states is (wait_1ms, start, finish);
    signal state : states;

    signal enable : std_logic;
    signal miso_data : std_logic_vector (7 downto 0);
    signal mosi_data : std_logic_vector (7 downto 0);
    signal data_ready : std_logic;

    component SPI_Master is
        generic (
            c_clkfreq  : integer;
            c_sclkfreq : integer;
            c_cpol     : std_logic := '0';
            c_cpha     : std_logic := '0'
        );
        port
        (
            clk_i        : in  std_logic;
            en_i         : in  std_logic;
            mosi_data_i  : in  std_logic_vector (7 downto 0);
            miso_data_o  : out std_logic_vector (7 downto 0);
            data_ready_o : out std_logic;
            cs_o         : out std_logic;
            sclk_o       : out std_logic;
            mosi_o       : out std_logic;
            miso_i       : in  std_logic
        );
    end component;

    type data_states is array (0 to 1) of std_logic_vector (7 downto 0);
    signal spi_data : data_states := (x"25", x"12");

begin

    --instantiate the SPI Master
    SPI_Master_0 : SPI_Master
    generic map(c_clkfreq => sys_clk_freq, c_sclkfreq => spi_clk_freq, c_cpol => '0', c_cpha => '0')
    port map
    (
        clk_i => clk, en_i => enable, mosi_data_i => mosi_data, miso_data_o => miso_data,
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
                    if (counter < sys_clk_freq/10000) then
                        counter := counter + 1;
                    else
                        counter := 0;
                        state <= start;
                    end if;

                when start =>
                    enable <= '1';
                    mosi_data <= spi_data(state_counter);
                    state <= finish;;

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