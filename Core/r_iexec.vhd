library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity r_iexec is

    port (
        clk     : in std_logic;
        reset   : in std_logic;

        i_inst  : in std_logic_vector (31 downto 0);
        o_inst  : out std_logic_vector (31 downto 0);

        i_pc    : in std_logic_vector (31 downto 0);

        i_imm   : in std_logic_vector (31 downto 0);
        i_arg1  : in std_logic_vector (31 downto 0);
        i_arg2  : in std_logic_vector (31 downto 0);

        i_alu_op    : in std_logic_vector (2 downto 0);
        i_alu_neg   : in std_logic;

        o_alu_res   : out std_logic_vector (31 downto 0)
    );

end entity;

architecture behavior of r_iexec is

    function ar_shift_right ( signal A1 : in unsigned (31 downto 0);
                              signal A2 : in unsigned (31 downto 0)
                            ) return unsigned is variable res : unsigned (31 downto 0);
    variable shamt : integer := to_integer (A2 (5 downto 0));

    subtype shamt_range is natural range 0 to 31;

    begin

        for i in shamt_range loop
            if (i < shamt) then
                res (31 - i) := A1 (31);
            end if;
            
            if (i <= 31 - shamt) then
                res (31 - shamt - i) := A1 (31 - i);
            end if;
        end loop;

        return res;
    end ar_shift_right;

    alias op : std_logic_vector (6 downto 0) is i_inst (6 downto 0);

    signal ar : unsigned (31 downto 0) := (others => '0');
    signal a1 : unsigned (31 downto 0) := (others => '0');
    signal a2 : unsigned (31 downto 0) := (others => '0');

begin

    a1_mux : process (i_inst)
        begin
            case op is 
                when OP_ADD =>
                    a1 <= unsigned (i_arg1);

                when OP_AUIPC =>
                    a1 <= unsigned (i_pc);

                when others =>
                    a1 <= (others => '0');
        end case;
    end process;

    a2_mux : process (i_inst)
    begin
        case op is
            when OP_ADD =>
                a2 <= unsigned (i_arg2);

            when OP_ADDI | OP_LB | OP_JALR | OP_LUI | OP_AUIPC =>
                a2 <= unsigned (i_imm);

            when others =>
                a2 <= (others => '0');
        end case;
    end process;

    alu : process (clk)
    begin
        if rising_edge (clk) then
            case i_alu_op is
                when "000" =>
                    if (i_alu_neg = '0') then
                        ar <= a1 + a2;
                    else
                        ar <= a1 - a2; -- TODO: use only one ALU
                    end if;
                
                when "001" =>
                    ar <= a1 sll to_integer (a2 (5 downto 0));

                when "010" =>
                    if (to_integer (a1) < to_integer (a2)) then
                        ar <= x"00000001";
                    else
                        ar <= x"00000000";
                    end if;
                
                when "011" =>
                    if (a1 < a2) then
                        ar <= x"00000001";
                    else
                        ar <= x"00000000";
                    end if;

                when "100" =>
                    ar <= a1 xor a2;

                when "101" =>
                    if (i_alu_neg = '0') then
                        ar <= a1 srl to_integer (a2 (5 downto 0));
                    else
                        ar <= ar_shift_right (a1, a2);
                    end if;
                
                when "110" =>
                    ar <= a1 or a2;
                
                when "111" =>
                    ar <= a1 and a2;

                when others =>
                    ar <= (others => '0');

            end case;

            o_inst <= i_inst;
        end if;
    end process;

    o_alu_res <= std_logic_vector (ar);

end architecture;