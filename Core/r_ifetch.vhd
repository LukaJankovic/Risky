library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity r_ifetch is

    port (
        clk     : in std_logic;
        reset   : in std_logic;

        o_iaddr : out std_logic_vector (31 downto 0)
    );

end entity;

architecture behavior of r_ifetch is

    signal pc   : std_logic_vector (31 downto 0) := (others => '0');

begin

    update_pc : process (clk)
    begin
        if rising_edge (clk) then
            if (reset = '1') then
                pc <= (others => '0');
            else
                pc <= std_logic_vector (unsigned (pc) + 4);
            end if;
        end if;
    end process;

    o_iaddr <= pc;

end architecture;