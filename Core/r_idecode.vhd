library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity r_idecode is

    port (
        clk     : in std_logic;
        reset   : in std_logic;

        i_inst  : in std_logic_vector (31 downto 0);
        o_inst  : out std_logic_vector (31 downto 0);
        i_pc    : in std_logic_vector (31 downto 0);
        o_pc    : out std_logic_vector (31 downto 0);

        o_imm   : out std_logic_vector (31 downto 0);
        o_rs1   : out std_logic_vector (4 downto 0);
        o_rs2   : out std_logic_vector (4 downto 0);
        
        o_alu_op    : out std_logic_vector (2 downto 0);
        o_alu_neg   : out std_logic;

        o_cmp_op    : out std_logic_vector (2 downto 0);

        o_next_pc   : out std_logic_vector (31 downto 0)
    );

end entity;

architecture behavior of r_idecode is

    signal instruction  : std_logic_vector (31 downto 0) := (others => '0');
    signal immediate    : std_logic_vector (31 downto 0) := (others => '0');

    alias op    : std_logic_vector (6 downto 0) is instruction (6 downto 0);

    alias rs1   : std_logic_vector (4 downto 0) is instruction (19 downto 15);
    alias rs2   : std_logic_vector (4 downto 0) is instruction (24 downto 20);

    alias alu_op    : std_logic_vector (2 downto 0) is instruction (14 downto 12);
    alias alu_neg   : std_logic is instruction (30);

    alias cmp_op    : std_logic_vector (2 downto 0) is instruction (14 downto 12);
begin

    -- TODO: test clocked processes

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

    decode_alu_op : process (instruction)
    begin
        case op is
            when OP_ADDI | OP_ADD =>
                o_alu_op <= alu_op;

            when others =>
                o_alu_op <= (others => '0');
        end case;
    end process;

    decode_cmp_op : process (instruction)
    begin
        case op is
            when OP_BEQ =>
                o_cmp_op <= cmp_op;

            when others =>
                o_cmp_op <= (others => '0');
        end case;
    end process;


    decode_branch : process (instruction)
    begin
        case op is
            when OP_BEQ =>
                o_next_pc <= std_logic_vector (unsigned (i_pc) + unsigned (immediate) - 5);

            when others =>
                o_next_pc <= (others => '0');
        end case;
    end process;

    pc : process (clk)
    begin
        if rising_edge (clk) then
            o_pc <= i_pc;
            o_inst <= i_inst;
        end if;
    end process;

    instruction <= i_inst;

    o_imm <= immediate;
    o_rs1 <= rs1;
    o_rs2 <= rs2;

    o_alu_neg <= alu_neg;

    -- TODO: calculate target pc when jump

end architecture;
