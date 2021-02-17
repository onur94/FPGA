library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity PCF8591_Uart_TX is
    generic
    (
        sys_clk_freq : integer := 50_000_000                  --input clock speed from user logic in Hz
    );               
    port
    (
        clk          : in    std_logic;                       --system clock
        reset        : in    std_logic;                       --asynchronous active-low reset
        scl          : inout std_logic;                       --I2C serial clock
        sda          : inout std_logic;                       --I2C serial data
        i2c_ack_err  : out   std_logic;                       --I2C slave acknowledge error flag
        adc_ch0_data : out   std_logic_vector(7 downto 0);    --ADC Channel 0 data obtained
        uart_output  : out   std_logic
    );
end PCF8591_Uart_TX;

architecture Behavioral of PCF8591_Uart_TX is
    type machine is(start, read_adc, output_result);     --needed states
    signal state        : machine;                        --state machine
    signal config       : std_logic_vector(7 downto 0);   --value to set the Sensor Configuration Register
    signal i2c_ena      : std_logic;                      --i2c enable signal
    signal i2c_addr     : std_logic_vector(6 downto 0);   --i2c address signal
    signal i2c_rw       : std_logic;                      --i2c read/write command signal
    signal i2c_data_wr  : std_logic_vector(7 downto 0);   --i2c write data
    signal i2c_data_rd  : std_logic_vector(7 downto 0);   --i2c read data
    signal i2c_busy     : std_logic;                      --i2c busy signal
    signal busy_prev    : std_logic;                      --previous value of i2c busy signal
    signal adc_buffer   : std_logic_vector(7 downto 0);   --ADC Channel data buffer

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
            scl       : inout  std_logic 					 --serial clock output of i2c bus
        );                   
    end component;
	
	signal uart_active : std_logic := '0';
	signal uart_data   : std_logic_vector(7 downto 0) := (others => '0');
	
	component UART_TX is
        generic 
        (
            g_CLKS_PER_BIT : integer
        );
        port 
        (
            i_Clk          : in  std_logic;
            i_TX_DV        : in  std_logic;
            i_TX_Byte      : in  std_logic_vector(7 downto 0);
            o_TX_Active    : out std_logic;
            o_TX_Serial    : out std_logic;
            o_TX_Done      : out std_logic
        );
	end component;

begin

  --instantiate the i2c master
  i2c_master_0:  I2C_Master
    generic map(input_clk => sys_clk_freq, bus_clk => 400_000)
    port map(clk => clk, reset => reset, ena => i2c_ena, addr => i2c_addr,
             rw => i2c_rw, data_wr => i2c_data_wr, busy => i2c_busy,
             data_rd => i2c_data_rd, ack_error => i2c_ack_err, sda => sda,
             scl => scl);
			 
  uart_tx_0: UarT_TX
    generic map(g_CLKS_PER_BIT => 434)  -- 50_000_000/115_200 = 434
    port map(i_Clk => clk, i_TX_DV => uart_active, i_TX_Byte => uart_data, 
             o_TX_Active => open, o_TX_Serial => uart_output, o_TX_Done => open);

  process(clk, reset)
    variable busy_cnt : integer range 0 to 2 := 0;            --counts the busy signal transistions during one transaction
    variable counter  : integer range 0 to sys_clk_freq/10 := 0; --counts 100ms to wait before communicating
  begin
    if(reset = '1') then               --reset activated
      counter := 0;                        --clear wait counter
      i2c_ena <= '0';                      --clear i2c enable
      busy_cnt := 0;                       --clear busy counter
      adc_ch0_data <= (others => '0');     --clear ADC Channel 0 result output
      state <= start;                      --return to start state
    elsif rising_edge(clk) then 	   --rising edge of system clock
      case state is                        --state machine
      
        --give ADC 100ms to power up before communicating
        when start =>
          if counter < sys_clk_freq/10 then   --100ms not yet reached
            counter := counter + 1;              --increment counter
          ELSE                                 --100ms reached
            counter := 0;                        --clear counter
            state <= read_adc;                   --initate ADC conversions and retrieve data
          end if;
        
        --initiate ADC conversions and retrieve data
        when read_adc =>
          busy_prev <= i2c_busy;                          --capture the value of the previous i2c busy signal
          if(busy_prev = '0' AND i2c_busy = '1') then     --i2c busy just went high
            busy_cnt := busy_cnt + 1;                       --counts the times busy has gone from low to high during transaction
          end if;
          case busy_cnt is                                --busy_cnt keeps track of which command we are on
            when 0 =>                                  --no command latched in yet
              i2c_ena <= '1';                            --initiate the transaction
              i2c_addr <= "1001000";                     --set the address of the slave
              i2c_rw <= '0';                             --command 0 is a write
              i2c_data_wr <= "01000011";                 --data to be written
            when 1 =>
                i2c_rw <= '1';                             --command 1 is a read
            when 2 =>          			               --2th busy high: command 2 latched, ready to st
              i2c_ena <= '0';                            --deassert enable to stop transaction after command 2
              if(i2c_busy = '0') then                    --indicates data read in command 2 is ready
                adc_buffer(7 downto 0) <= i2c_data_rd;   --retrieve data from command 2
                busy_cnt := 0;                           --reset busy_cnt for next transaction
                state <= output_result;                  --transaction complete, go to next state in design
              end if;
              uart_active <= '1';
            when others => NULL;
          end case;

        --match received ADC data to outputs
        when output_result =>
            uart_data <= adc_buffer;
            uart_active <= '0';
            state <= start;
			
        --default to start state
        when others =>
          state <= start;
      end case;
    end if;
  end process;   
end Behavioral;
