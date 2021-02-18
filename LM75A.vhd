library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LM75A is
    generic 
    (
        sys_clk_freq : integer := 50_000_000
    );
    port
    (
        clk         : in    std_logic;
        reset       : in    std_logic;
        scl         : inout std_logic;
        sda         : inout std_logic;
        i2c_ack_err : out   std_logic;
        adc_output  : out   std_logic_vector(7 downto 0);
        uart_output : out   std_logic
    );
end LM75A;

architecture Behavioral of LM75A is
    type machine is(start, start_adc, read_data, finish);   --needed states
    signal state : machine;                                 --state machine
    signal config       : std_logic_vector(7 downto 0);     --value to set the Sensor Configuration Register
    signal i2c_ena      : std_logic;                        --i2c enable signal
    signal i2c_addr     : std_logic_vector(6 downto 0);     --i2c address signal
    signal i2c_rw       : std_logic;                        --i2c read/write command signal
    signal i2c_data_wr  : std_logic_vector(7 downto 0);     --i2c write data
    signal i2c_data_rd  : std_logic_vector(7 downto 0);     --i2c read data
    signal i2c_busy     : std_logic;                        --i2c busy signal
    signal busy_prev    : std_logic;                        --previous value of i2c busy signal
    signal temp_data    : std_logic_vector(15 downto 0);    --temp data buffer
    signal temperature	: std_logic_vector(7 downto 0);     --temp value

    component I2C_Master is
        generic 
        (
            input_clk : integer;  --input clock speed from user logic in Hz
            bus_clk   : integer   --speed the i2c bus (scl) will run at in Hz
        ); 
        port
        (
            clk       : in     std_logic;                    --system clock
            reset     : in     std_logic;                    --active low reset
            ena       : in     std_logic;                    --latch in command
            addr      : in     std_logic_vector(6 downto 0); --address of target slave
            rw        : in     std_logic;                    --'0' is write, '1' is read
            data_wr   : in     std_logic_vector(7 downto 0); --data to write to slave
            busy      : out    std_logic;                    --indicates transaction in progress
            data_rd   : out    std_logic_vector(7 downto 0); --data read from slave
            ack_error : buffer std_logic;                    --flag if improper acknowledge from slave
            sda       : inout  std_logic;                    --serial data output of i2c bus
            scl       : inout  std_logic                     --serial clock output of i2c bus
        );                   
    end component;

    signal uart_active : std_logic := '0';
    signal uart_data : std_logic_vector(7 downto 0) := (others => '0');

    component UART_TX is
        generic 
        (
            g_CLKS_PER_BIT : integer
        );
        port
        (
            i_Clk       : in  std_logic;
            i_TX_DV     : in  std_logic;
            i_TX_Byte   : in  std_logic_vector(7 downto 0);
            o_TX_Active : out std_logic;
            o_TX_Serial : out std_logic;
            o_TX_Done   : out std_logic
        );
    end component;

begin

    --instantiate the i2c master
    i2c_master_0 : I2C_Master
        generic map(input_clk => sys_clk_freq, bus_clk => 400_000)
        port map(clk => clk, reset => reset, ena => i2c_ena, addr => i2c_addr,
                 rw => i2c_rw, data_wr => i2c_data_wr, busy => i2c_busy,
                 data_rd => i2c_data_rd, ack_error => i2c_ack_err, sda => sda,
                 scl => scl);

    uart_tx_0 : UART_TX
        generic map(g_CLKS_PER_BIT => 434) -- 50_000_000/115_200 = 434
        port map(i_Clk => clk, i_TX_DV => uart_active, i_TX_Byte => temperature,
                 o_TX_Active => open, o_TX_Serial => uart_output, o_TX_Done => open);

    process (clk, reset)
        variable busy_cnt : integer range 0 to 3 := 0;
        variable counter : integer range 0 to sys_clk_freq := 0;
    begin
        if (reset = '1') then
            counter := 0;
            i2c_ena <= '0';
            busy_cnt := 0;
            temp_data <= (others => '0');
            state <= start;
            uart_active <= '0';
        elsif rising_edge(clk) then
            case state is

                when start =>
                    if (counter < sys_clk_freq) then
                        counter := counter + 1;
                    else
                        counter := 0;
                        state <= start_adc;
                    end if;

                --start Temperature Request
                when start_adc =>
                    busy_prev <= i2c_busy;
                    if (busy_prev = '0' and i2c_busy = '1') then
                        busy_cnt := busy_cnt + 1;
                    end if;
                    case busy_cnt is
                        when 0 =>
                            i2c_ena <= '1';
                            i2c_addr <= "1001000";
                            i2c_rw <= '0';
                            i2c_data_wr <= "00000000";
                        when 1 =>
                            i2c_rw <= '1';
                        when 2 =>
                            if (i2c_busy = '0') then
                                temp_data(15 downto 8) <= i2c_data_rd;
                            end if;
                        when 3 =>
                            i2c_ena <= '0';
                            if (i2c_busy = '0') then
                                temp_data(7 downto 0) <= i2c_data_rd;
                                uart_active <= '1';
                                busy_cnt := 0;
                                state <= finish;
                            end if;
                        when others => null;
                    end case;

                --output the Temperature value
                when finish =>
                    temperature <= temp_data(14 downto 7);
                    uart_active <= '0';
                    state <= start;

                --default to start state
                when others =>
                    state <= start;

            end case;
        end if;
    end process;
end Behavioral;