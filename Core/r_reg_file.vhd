library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity r_reg_file is

    port (
        clk :   in std_logic;
        reset : in std_logic;

        i_addr : in std_logic_vector (4 downto 0);
        i_data : in std_logic_vector (31 downto 0);
        o_data : out std_logic_vector (31 downto 0);
        i_we : in std_logic
    );

end r_reg_file;

architecture behavior of r_reg_file is

    type regfile is array (0 to 31) of std_logic_vector (31 downto 0);
    signal registers : regfile := (others => (others => '0'));

begin

    process (clk) begin
        if rising_edge (clk) then
            if (reset = '1') then
                registers <= (others => (others => '0'));
            else
                if (i_we = '1') then
                    registers (to_integer (unsigned (i_addr))) <= i_data;
                end if;

                o_data <= registers (to_integer (unsigned (i_addr)));
            end if;
        end if;
    end process;

end behavior;