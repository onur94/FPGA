--------------------------------------------------------------------------------
--
--   FileName:         pmod_adc_ad7991.vhd
--   Dependencies:     i2c_master.vhd (Version 2.2)
--   Design Software:  Quartus Prime Version 17.0.0 Build 595 SJ Lite Edition
--
--   HDL CODE is PROVIDED "AS is."  DIGI-KEY EXPRESSLY DisCLAIMS ANY
--   WARRANTY of ANY KinD, WHETHER EXPRESS OR IMPLIED, inCLUDinG BUT NOT
--   LIMITED to, THE IMPLIED WARRANTIES of MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-inFRinGEMENT. in NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY inCIDENTAL, SPECIAL, inDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PRofITS OR LOST DATA, HARM to YOUR EQUIPMENT, COST of
--   PROCUREMENT of SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (inCLUDinG BUT NOT LIMITED to ANY DEFENSE THEREof),
--   ANY CLAIMS FOR inDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 09/18/2020 Scott Larson
--     initial Public Release
-- 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;

entity PCF8591 is
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
        adc_ch0_data : out   std_logic_vector(7 downto 0)     --ADC Channel 0 data obtained
    );
end PCF8591;

architecture behavior of PCF8591 is
    type machine is(start, read_data, output_result);     --needed states
    signal state        : machine;                        --state machine
    signal config       : std_logic_vector(7 downto 0);   --value to set the Sensor Configuration Register
    signal i2c_ena      : std_logic;                      --i2c enable signal
    signal i2c_addr     : std_logic_vector(6 downto 0);   --i2c address signal
    signal i2c_rw       : std_logic;                      --i2c read/write command signal
    signal i2c_data_wr  : std_logic_vector(7 downto 0);   --i2c write data
    signal i2c_data_rd  : std_logic_vector(7 downto 0);   --i2c read data
    signal i2c_busy     : std_logic;                      --i2c busy signal
    signal busy_prev    : std_logic;                      --previous value of i2c busy signal
    signal adc_buffer   : std_logic_vector(7 downto 0);   --ADC Channel 0 data buffer

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
            scl       : inout  std_logic 					   --serial clock output of i2c bus
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

  process(clk, reset)
    variable busy_cnt : integer range 0 to 2 := 0;            --counts the busy signal transistions during one transaction
    variable counter  : integer range 0 to sys_clk_freq := 0; --counts 100ms to wait before communicating
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
          if counter < sys_clk_freq then   --100ms not yet reached
            counter := counter + 1;              --increment counter
          ELSE                                 --100ms reached
            counter := 0;                        --clear counter
            state <= read_data;                  --initate ADC conversions and retrieve data
          end if;
        
        --initiate ADC conversions and retrieve data
        when read_data =>
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
            when 1 =>                                  --1st busy high: command 1 latched, okay to issue command 2
              i2c_rw <= '1';                             --command 1 is a read (addr stays the same)
            when 2 =>                                  --2th busy high: command 4 latched, ready to stop
              i2c_ena <= '0';                            --deassert enable to stop transaction after command 2
              if(i2c_busy = '0') then                    --indicates data read in command 2 is ready
                adc_buffer(7 downto 0) <= i2c_data_rd;   --retrieve data from command 4
                busy_cnt := 0;                             --reset busy_cnt for next transaction
                state <= output_result;                    --transaction complete, go to next state in design
              end if;
            when others => NULL;
          end case;

        --match received ADC data to outputs
        when output_result =>
          adc_ch0_data <= adc_buffer;
          state <= start;
			
        --default to start state
        when others =>
          state <= start;
      end case;
    end if;
  end process;   
end behavior;
