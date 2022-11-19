library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity r_reg_file is

    port (
        clk :   in std_logic;
        reset : in std_logic;

        i_addr1 : in std_logic_vector (4 downto 0);
        o_data1 : out std_logic_vector (31 downto 0) := (others => '0');

        i_addr2 : in std_logic_vector (4 downto 0);
        o_data2 : out std_logic_vector (31 downto 0) := (others => '0');

        i_waddr : in std_logic_vector (4 downto 0);
        i_wdata : in std_logic_vector (31 downto 0);
        i_we : in std_logic
    );

end entity;

architecture behavior of r_reg_file is

    type regfile is array (0 to 31) of std_logic_vector (31 downto 0);
    signal registers : regfile := (others => (others => '0'));

begin

    regfile_access : process (clk)
    begin
        if rising_edge (clk) then
            if (reset = '1') then
                registers <= (others => (others => '0'));
            else
                if (i_we = '1') and (i_waddr /= "0000") then
                    registers (to_integer (unsigned (i_waddr))) <= i_wdata;
                end if;

                -- TODO: move outside process?
                o_data1 <= registers (to_integer (unsigned (i_addr1)));
                o_data2 <= registers (to_integer (unsigned (i_addr2)));
            end if;
        end if;
    end process;

end architecture;
