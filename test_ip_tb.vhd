----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/06/2022 07:59:34 PM
-- Design Name: 
-- Module Name: test_ip_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_ip_tb is
--  Port ( );
end test_ip_tb;

architecture tb of test_ip_tb is
    component design_test_ip is
        port
        (
            LEDs_out_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
            S00_AXI_0_araddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_0_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
            S00_AXI_0_arready : out STD_LOGIC;
            S00_AXI_0_arvalid : in STD_LOGIC;
            S00_AXI_0_awaddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_0_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
            S00_AXI_0_awready : out STD_LOGIC;
            S00_AXI_0_awvalid : in STD_LOGIC;
            S00_AXI_0_bready : in STD_LOGIC;
            S00_AXI_0_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            S00_AXI_0_bvalid : out STD_LOGIC;
            S00_AXI_0_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
            S00_AXI_0_rready : in STD_LOGIC;
            S00_AXI_0_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
            S00_AXI_0_rvalid : out STD_LOGIC;
            S00_AXI_0_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
            S00_AXI_0_wready : out STD_LOGIC;
            S00_AXI_0_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_0_wvalid : in STD_LOGIC;
            s00_axi_aclk_0 : in STD_LOGIC;
            s00_axi_aresetn_0 : in STD_LOGIC
        );
    end component;
    
    signal LEDcontroller_0_LEDs_out : STD_LOGIC_VECTOR ( 7 downto 0 );
    signal S00_AXI_0_1_ARADDR : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal S00_AXI_0_1_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal S00_AXI_0_1_ARREADY : STD_LOGIC;
    signal S00_AXI_0_1_ARVALID : STD_LOGIC;
    signal S00_AXI_0_1_AWADDR : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal S00_AXI_0_1_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
    signal S00_AXI_0_1_AWREADY : STD_LOGIC;
    signal S00_AXI_0_1_AWVALID : STD_LOGIC;
    signal S00_AXI_0_1_BREADY : STD_LOGIC;
    signal S00_AXI_0_1_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal S00_AXI_0_1_BVALID : STD_LOGIC;
    signal S00_AXI_0_1_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal S00_AXI_0_1_RREADY : STD_LOGIC;
    signal S00_AXI_0_1_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal S00_AXI_0_1_RVALID : STD_LOGIC;
    signal S00_AXI_0_1_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal S00_AXI_0_1_WREADY : STD_LOGIC;
    signal S00_AXI_0_1_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal S00_AXI_0_1_WVALID : STD_LOGIC;
    signal s00_axi_aclk_0_1 : STD_LOGIC := '0';
    signal s00_axi_aresetn_0_1 : STD_LOGIC := '0';
    
begin
    clk_stimulus : process
    begin
        s00_axi_aclk_0_1 <= s00_axi_aclk_0_1 xor '1';
        wait for 5 ns;
    end process;
    
    uut : design_test_ip port map
    (
        LEDcontroller_0_LEDs_out,
        S00_AXI_0_1_ARADDR,
        S00_AXI_0_1_ARPROT,
        S00_AXI_0_1_ARREADY,
        S00_AXI_0_1_ARVALID,
        S00_AXI_0_1_AWADDR,
        S00_AXI_0_1_AWPROT,
        S00_AXI_0_1_AWREADY,
        S00_AXI_0_1_AWVALID,
        S00_AXI_0_1_BREADY,
        S00_AXI_0_1_BRESP,
        S00_AXI_0_1_BVALID,
        S00_AXI_0_1_RDATA,
        S00_AXI_0_1_RREADY,
        S00_AXI_0_1_RRESP,
        S00_AXI_0_1_RVALID,
        S00_AXI_0_1_WDATA,
        S00_AXI_0_1_WREADY,
        S00_AXI_0_1_WSTRB,
        S00_AXI_0_1_WVALID,
        s00_axi_aclk_0_1,
        s00_axi_aresetn_0_1
    );
    
    data_stimulus : process
    begin
        s00_axi_aresetn_0_1 <= '0';
        wait for 20 ns;
        s00_axi_aresetn_0_1 <= '1';
        wait for 30 ns;
        S00_AXI_0_1_AWADDR <= x"0";
        S00_AXI_0_1_WDATA <= x"00000050";
        S00_AXI_0_1_AWVALID <= '1';
        S00_AXI_0_1_WVALID <= '1';
        S00_AXI_0_1_BREADY <= '1';
        S00_AXI_0_1_WSTRB <= x"F";
        
        wait until S00_AXI_0_1_BVALID = '1';
        S00_AXI_0_1_AWADDR <= x"0";
        S00_AXI_0_1_WDATA <= x"00000000";
        S00_AXI_0_1_AWVALID <= '0';
        S00_AXI_0_1_WVALID <= '0';
        S00_AXI_0_1_BREADY <= '0';
        S00_AXI_0_1_WSTRB <= x"0";
        wait for 40 ns;
        
        assert false report "Test: OK" severity failure;
    end process;
end tb;