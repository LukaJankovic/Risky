library ieee;
library work;

use ieee.std_logic_1164.all;
use work.constants.all;

entity r_idecode is

    port (
        clk     : in std_logic;
        reset   : in std_logic;

        i_inst  : in std_logic_vector (31 downto 0);

        o_imm   : out std_logic_vector (31 downto 0);
        o_rs1   : out std_logic_vector (4 downto 0);
        o_rs2   : out std_logic_vector (4 downto 0)
    );

end r_idecode;

architecture behavior of r_idecode is

    signal instruction  : std_logic_vector (31 downto 0) := (others => '0');
    signal immediate    : std_logic_vector (31 downto 0) := (others => '0');

    alias op    : std_logic_vector (6 downto 0) is instruction (6 downto 0);

    alias rs1   : std_logic_vector (4 downto 0) is instruction (19 downto 15);
    alias rs2   : std_logic_vector (4 downto 0) is instruction (24 downto 20);

begin

    decode_immediate : process (instruction)
    begin
        case op is
            when OP_JALR | OP_LB | OP_ADDI => -- I type
                immediate <= (31 downto 12 => instruction (31)) & instruction (31 downto 20);
            when OP_SB => -- S type
                immediate <= (31 downto 12 => instruction (31)) & instruction (31 downto 25) & instruction (11 downto 7);
            when OP_BEQ => -- B type
                immediate <= (31 downto 13 => instruction (31)) & instruction (31) & instruction (7) & instruction (30 downto 25) & instruction (11 downto 8) & '0';
            when OP_LUI | OP_AUIPC => -- U type
                immediate <= instruction (31 downto 12) & (11 downto 0 => '0');
            when OP_JAL => -- J type
                immediate <= (31 downto 21 => instruction (31)) & instruction(31) & instruction (19 downto 12) & instruction (20) & instruction (30 downto 21) & '0';
            when others => -- R type, ...
                immediate <= (others => '0');
        end case;
    end process;

    instruction <= i_inst;

    o_imm <= immediate;
    o_rs1 <= rs1;
    o_rs2 <= rs2;

    -- TODO: calculate target pc when jump

end architecture;