library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SPI_Slave_Read is
    port
    (
        clk        : in  std_logic;
        rst        : in  std_logic;
        data_in    : in  std_logic_vector (7 downto 0);
        sclk       : in  std_logic;
        mosi       : in  std_logic;
        miso       : out std_logic;
        cs         : in  std_logic;
        data_valid : out std_logic;
        wrack_out  : out std_logic;
        pattern    : out std_logic;
        wren_out   : out std_logic
    );
end SPI_Slave_Read;

architecture Behavioral of SPI_Slave_Read is
    type states is (idle, sent);
    signal state : states;

    signal mosi_data : std_logic_vector (7 downto 0);
    signal miso_data : std_logic_vector (7 downto 0);
    signal do_valid : std_logic;
    signal data_sent : std_logic := '0';
    signal wren : std_logic;

    component SPI_Slave is
        generic (
            N        : positive  := 8;   -- 32bit serial word length is default
            CPOL     : std_logic := '0'; -- SPI mode selection (mode 0 default)
            CPHA     : std_logic := '0'; -- CPOL = clock polarity, CPHA = clock phase.
            PREFETCH : positive  := 1);  -- prefetch lookahead cycles
        port
        (
            clk_i      : in  std_logic  := 'X';                                    -- internal interface clock (clocks di/do registers)
            spi_ssel_i : in  std_logic  := 'X';                                    -- spi bus slave select line
            spi_sck_i  : in  std_logic  := 'X';                                    -- spi bus sck clock (clocks the shift register core)
            spi_mosi_i : in  std_logic  := 'X';                                    -- spi bus mosi input
            spi_miso_o : out std_logic := 'X';                                     -- spi bus spi_miso_o output
            di_req_o   : out std_logic;                                            -- preload lookahead data request line
            di_i       : in  std_logic_vector (N - 1 downto 0) := (others => 'X'); -- parallel load data in (clocked in on rising edge of clk_i)
            wren_i     : in  std_logic                         := 'X';             -- user data write enable
            wr_ack_o   : out std_logic;                                            -- write acknowledge
            do_valid_o : out std_logic;                                            -- do_o data valid strobe, valid during one clk_i rising edge.
            do_o       : out std_logic_vector (N - 1 downto 0);                    -- parallel output (clocked out on falling clk_i)
            --- debug ports: can be removed for the application circuit ---
            do_transfer_o : out std_logic;                        -- debug: internal transfer driver
            wren_o        : out std_logic;                        -- debug: internal state of the wren_i pulse stretcher
            rx_bit_next_o : out std_logic;                        -- debug: internal rx bit
            state_dbg_o   : out std_logic_vector (3 downto 0);    -- debug: internal state register
            sh_reg_dbg_o  : out std_logic_vector (N - 1 downto 0) -- debug: internal shift register
        );
    end component;
begin

    --instantiate the SPI Slave
    SPI_Slave_0 : SPI_Slave
        generic map(N => 8, CPOL => '0', CPHA => '0', PREFETCH => 1)
        port map(clk_i => clk, spi_ssel_i => cs, spi_sck_i => sclk, spi_mosi_i => mosi, spi_miso_o => miso,
                 di_req_o => open, di_i => miso_data, wren_i => wren, wr_ack_o => wrack_out, do_valid_o => data_valid,
                 do_o => mosi_data);

    wren_out <= wren;

    process (clk)
    begin
        if rst = '1' then
            wren <= '0';
        elsif rising_edge(clk) then
            wren <= '0';
            if data_valid = '1' then
                case mosi_data is
                    when x"34" =>
                        miso_data <= x"5A";
                        wren <= '1';
                        pattern <= '1';
                    when x"67" =>
                        miso_data <= x"AB";
                        wren <= '1';
                        pattern <= '1';
                    when x"89" =>
                        miso_data <= x"11";
                        wren <= '1';
                        pattern <= '1';
                    when others =>
                        miso_data <= (others => '0');
                        wren <= '1';
                        pattern <= '0';
                end case;
            end if;
            case state is
                when idle =>
                    if data_sent = '1' then
                        wren <= '1';
                        state <= sent;
                    end if;
                when sent =>
                    wren <= '0';
                    state <= idle;
            end case;

        end if;
    end process;
end Behavioral;