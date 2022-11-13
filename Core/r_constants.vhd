library ieee;
use ieee.std_logic_1164.all;

package constants is

    constant OP_LUI     : std_logic_vector (6 downto 0) := "0110111";
    constant OP_AUIPC   : std_logic_vector (6 downto 0) := "0010111";
    constant OP_ADDI    : std_logic_vector (6 downto 0) := "0010011";
    constant OP_ADD     : std_logic_vector (6 downto 0) := "0110011";
    constant OP_LB      : std_logic_vector (6 downto 0) := "0000011"; 
    constant OP_SB      : std_logic_vector (6 downto 0) := "0100011";
    constant OP_BEQ     : std_logic_vector (6 downto 0) := "1100011";
    constant OP_JAL     : std_logic_vector (6 downto 0) := "1101111";
    constant OP_JALR    : std_logic_vector (6 downto 0) := "1100111";

end package;

package body constants is
end package body;