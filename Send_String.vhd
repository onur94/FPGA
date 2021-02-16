library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_sTD.ALL;

entity Send_String is
    port
    (
        clk     : in  std_logic;
        hex_out : out std_logic_vector (7 downto 0) := (others => 'Z')
    );
end Send_String;

architecture Behavioral of Send_String is
    signal message : string (1 to 10) := (others => ' ');
    signal data : integer range 0 to 2000000000 := 1030067891;  -- data to be converted to string

    type my_states is (PREPARE, SEND);
    signal state : my_states;

    signal data_length : integer := integer'image(data)'length;

begin
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
                        hex_out <= std_logic_vector(to_unsigned(character'pos(message(m_index)), 8));
                        m_index := m_index + 1;
                    elsif m_index > message'length then
                        hex_out <= (others => 'Z');
                        state <= PREPARE;
                        data <= 698645;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;