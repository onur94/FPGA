library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity sqrt_ip is
  port (
      clk : in std_logic;
      data_out : out std_logic_vector (31 downto 0)
  );
end sqrt_ip;

architecture Behavioral of sqrt_ip is
    component floating_point_0
    port (
        aclk : in STD_LOGIC;
        aresetn : in STD_LOGIC;
        s_axis_a_tvalid : in STD_LOGIC;
        s_axis_a_tready : out STD_LOGIC;
        s_axis_a_tdata : in STD_LOGIC_VECTOR(31 downto 0);
        m_axis_result_tvalid : out STD_LOGIC;
        m_axis_result_tready : in STD_LOGIC;
        m_axis_result_tdata : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;
    
    signal aclk : STD_LOGIC;
    signal aresetn : STD_LOGIC := '0';
    signal s_axis_a_tvalid : STD_LOGIC := '0';
    signal s_axis_a_tready : STD_LOGIC;
    signal s_axis_a_tdata : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal m_axis_result_tvalid : STD_LOGIC;
    signal m_axis_result_tready : STD_LOGIC := '0';
    signal m_axis_result_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    type my_states is (reset, send_data, send_data_2, wait_data);
    signal state : my_states := reset;
       
begin
    your_instance_name : floating_point_0
    PORT MAP (
        aclk => clk,
        aresetn => aresetn,
        s_axis_a_tvalid => s_axis_a_tvalid,
        s_axis_a_tready => s_axis_a_tready,
        s_axis_a_tdata => s_axis_a_tdata,
        m_axis_result_tvalid => m_axis_result_tvalid,
        m_axis_result_tready => m_axis_result_tready,
        m_axis_result_tdata => m_axis_result_tdata
    );
    
    process (clk)
        variable counter : integer := 0;
    begin
        if rising_edge(clk) then
            case state is
                when reset =>
                    data_out <= (others => '0');
                    if counter < 3 then
                        counter := counter + 1;
                    else
                        aresetn <= '1';
                        state <= send_data;
                    end if;
                when send_data =>
                    m_axis_result_tready <= '1';
                    if s_axis_a_tready = '1' then
                        s_axis_a_tdata <= x"41100000";
                        s_axis_a_tvalid <= '1';  
                        state <= send_data_2;
                    end if;
                when send_data_2 =>
                    s_axis_a_tdata <= x"43800000";
                    state <= wait_data;
                when wait_data =>
                    s_axis_a_tvalid <= '0';
                    if m_axis_result_tvalid = '1' then
                        data_out <= m_axis_result_tdata;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
