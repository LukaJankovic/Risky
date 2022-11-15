library ieee;
library work;

use ieee.std_logic_1164.all;

use work.constants.all;

entity r_memory is

    port (
        clk     : in std_logic; 
        reset   : in std_logic;

        i_inst  : in std_logic_vector (31 downto 0);
        o_inst  : out std_logic_vector (31 downto 0);

        i_ar    : in std_logic_vector (31 downto 0);
        o_ar    : out std_logic_vector (31 downto 0);
        
        o_addr  : out std_logic_vector (31 downto 0);
        o_we    : out std_logic
    );

end entity;

architecture behavior of r_memory is

    alias op    : std_logic_vector (6 downto 0) is i_inst (6 downto 0);

begin

    mem_request : process (i_inst, i_ar)
    begin
        case op is
            when OP_LB =>
                o_addr <= i_ar;
                o_we <= '0';
            when OP_SB =>
                o_addr <= i_ar;
                o_we <= '1';
            when others =>
                o_addr <= (others => '0');
                o_we <= '0';
        end case;
    end process;

    inst_fwd : process (clk)
    begin
        if rising_edge (clk) then
            o_inst <= i_inst;
            o_ar <= i_ar;
        end if;
    end process;

end architecture;