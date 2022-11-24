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

        i_next_pc   : in std_logic_vector (31 downto 0);
        i_cmp_op    : in std_logic_vector (2 downto 0);

        o_alu_res   : out std_logic_vector (31 downto 0);
        o_cmp_res   : out std_logic;
        o_mdata     : out std_logic_vector (31 downto 0);
        o_next_pc   : out std_logic_vector (31 downto 0)
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

    alias rs1   : std_logic_vector (4 downto 0) is i_inst (19 downto 15);
    alias rs2   : std_logic_vector (4 downto 0) is i_inst (24 downto 20);
    alias rd : std_logic_vector (4 downto 0) is i_inst (11 downto 7);

    signal arg1 : std_logic_vector (31 downto 0) := (others => '0');
    signal arg2 : std_logic_vector (31 downto 0) := (others => '0');

    signal ar : unsigned (31 downto 0) := (others => '0');
    signal a1 : unsigned (31 downto 0) := (others => '0');
    signal a2 : unsigned (31 downto 0) := (others => '0');

    signal cr : std_logic;

    signal prev_dest    : std_logic_vector (4 downto 0) := (others => '0');

begin

    data_fwd : process (i_inst)
    begin
        if (prev_dest = rs1) then
            arg1 <= std_logic_vector (ar);
            arg2 <= i_arg2;

        elsif (prev_dest = rs2) then
            arg1 <= i_arg1;
            arg2 <= std_logic_vector (ar);

        else
            arg1 <= i_arg1;
            arg2 <= i_arg2;

        end if;
    end process;

    a1_mux : process (i_inst, arg1)
    begin
        case op is 
            when OP_ADD | OP_ADDI | OP_LB | OP_SB =>
                a1 <= unsigned (arg1);

            when OP_AUIPC =>
                a1 <= unsigned (i_pc);

            when others =>
                a1 <= (others => '0');
        end case;
    end process;

    a2_mux : process (i_inst, arg2)
    begin
        case op is
            when OP_ADD =>
                a2 <= unsigned (arg2);

            when OP_ADDI | OP_LB | OP_JALR | OP_LUI | OP_AUIPC | OP_SB =>
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

        end if;
    end process;

    comparator : process (clk)
    begin
        if rising_edge (clk) then
            case op is
                when OP_BEQ =>
                    o_next_pc <= i_next_pc;
                    o_cmp_res <= cr;
                
                when others =>
                    o_next_pc <= (others => 'X');
                    o_cmp_res <= '0';

            end case;
        end if;
    end process;

    reg : process (clk)
    begin
        if rising_edge (clk) then
            o_inst <= i_inst;
            o_mdata <= i_arg2;
        end if;
    end process;

    save_df : process (clk)
    begin
        if rising_edge (clk) then
            prev_dest <= rd;
        end if;
    end process;

    o_alu_res <= std_logic_vector (ar);
    
    -- Comparator (TODO: move to file)

    cr <= '1' when (arg1 = arg2)                    and (i_cmp_op = "000") else
          '1' when (arg1 /= arg2)                   and (i_cmp_op = "001") else
          '1' when (signed (arg1) < signed (arg2))  and (i_cmp_op = "100") else
          '1' when (signed (arg1) >= signed (arg2)) and (i_cmp_op = "101") else
          '1' when (arg1 < arg2)                    and (i_cmp_op = "110") else
          '1' when (arg1 >= arg2)                   and (i_cmp_op = "111") else
          '0';


end architecture;
