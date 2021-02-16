library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_sTD.all;

entity Send_String_to_FIFO is
    port
    (
        clk     : in  std_logic;
        hex_out : out std_logic_vector (7 downto 0) := (others => 'Z')
    );
end Send_String_to_FIFO;

architecture Behavioral of Send_String_to_FIFO is
    constant c_DEPTH    : integer := 32;
    constant c_WIDTH    : integer := 8;
    constant c_AF_LEVEL : integer := 30;
    constant c_AE_LEVEL : integer := 4;

    signal r_RESET      : std_logic := '0';
    signal r_CLOCK      : std_logic := '0';
    signal r_WR_EN      : std_logic := '0';
    signal r_WR_DATA    : std_logic_vector(c_WIDTH - 1 downto 0);
    signal w_AF         : std_logic;
    signal w_FULL       : std_logic;
    signal r_RD_EN      : std_logic := '0';
    signal w_RD_DATA    : std_logic_vector(c_WIDTH - 1 downto 0);
    signal w_AE         : std_logic;
    signal w_EMPTY      : std_logic;

    component FIFO is
        generic (
            g_WIDTH    : natural := 8;
            g_DEPTH    : integer := 32;
            g_AF_LEVEL : integer := 28;
            g_AE_LEVEL : integer := 4
        );
        port
        (
            i_rst_sync : in std_logic;
            i_clk      : in std_logic;

            -- FIFO Write Interface
            i_wr_en   : in  std_logic;
            i_wr_data : in  std_logic_vector(g_WIDTH - 1 downto 0);
            o_af      : out std_logic;
            o_full    : out std_logic;

            -- FIFO Read Interface
            i_rd_en   : in  std_logic;
            o_rd_data : out std_logic_vector(g_WIDTH - 1 downto 0);
            o_ae      : out std_logic;
            o_empty   : out std_logic
        );
    end component FIFO;
    signal message : string (1 to 10) := (others => ' ');
    signal data : integer range 0 to 2000000000 := 12345;

    type my_states is (PREPARE, SEND);
    signal state : my_states;

    signal data_length : integer := integer'image(data)'length;

begin
    component_fifo : FIFO
    generic map(
        g_WIDTH    => c_WIDTH,
        g_DEPTH    => c_DEPTH,
        g_AF_LEVEL => c_AF_LEVEL,
        g_AE_LEVEL => c_AE_LEVEL
    )
    port map
    (
        i_rst_sync => r_RESET,
        i_clk      => r_CLOCK,
        i_wr_en    => r_WR_EN,
        i_wr_data  => r_WR_DATA,
        o_af       => w_AF,
        o_full     => w_FULL,
        i_rd_en    => r_RD_EN,
        o_rd_data  => w_RD_DATA,
        o_ae       => w_AE,
        o_empty    => w_EMPTY
    );
    data_length <= integer'image(data)'length;
    process (clk)
        variable m_index : integer range 0 to (message'length + 1) := 0;
    begin
        if rising_edge(clk) then
            case state is
                when PREPARE =>
                    message <= (others => ' ');
                    for i in 1 to data_length loop
                        message(i) <= integer'image(data)(i);
                    end loop;
                    state <= SEND;
                    m_index := 1;

                when SEND =>
                    if m_index <= message'length then
                        if w_AF = '0' then
                            r_wR_EN <= '1';
                            hex_out <= std_logic_vector(to_unsigned(character'pos(message(m_index)), 8));
                            r_WR_DATA <= std_logic_vector(to_unsigned(character'pos(message(m_index)), 8));
                            m_index := m_index + 1;
                        else
                            r_wR_EN <= '0';
                        end if;
                    elsif m_index > message'length then
                        r_wR_EN <= '0';
                        hex_out <= (others => 'Z');
                        data <= 458;
                        state <= PREPARE;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;