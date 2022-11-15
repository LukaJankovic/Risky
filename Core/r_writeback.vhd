library ieee;
library work;

use ieee.std_logic_1164.all;

use work.constants.all;


entity r_writeback is
    
    port (
        clk     : in std_logic;
        reset   : in std_logic;

        i_inst  : in std_logic_vector (31 downto 0);

        i_ar    : in std_logic_vector (31 downto 0);
        i_mem   : in std_logic_vector (31 downto 0);

        o_reg_addr  : out std_logic_vector (4 downto 0);
        o_reg_data  : out std_logic_vector (31 downto 0);
        o_reg_we    : out std_logic
    );

end entity;

architecture behavior of r_writeback is

    alias op : std_logic_vector (6 downto 0) is i_inst (6 downto 0);
    alias rd : std_logic_vector (4 downto 0) is i_inst (11 downto 7);

    alias load_opt : std_logic_vector (2 downto 0) is i_inst (14 downto 12);

begin

    writeback : process (clk)
    begin
        if rising_edge (clk) then
            case op is
                when OP_ADD | OP_ADDI | OP_LUI =>
                    o_reg_addr <= rd;
                    o_reg_data <= i_ar;
                    o_reg_we <= '1';

                when OP_LB =>
                    o_reg_addr <= rd;
                    o_reg_we <= '1';

                    case load_opt is
                        when "000" =>
                            o_reg_data <= (31 downto 7 => i_mem (7)) & i_mem (6 downto 0);

                        when "001" =>
                            o_reg_data <= (31 downto 15 => i_mem (15)) & i_mem (14 downto 0);

                        when "010" =>
                            o_reg_data <= i_mem;

                        when "100" =>
                            o_reg_data <= (31 downto 8 => '0') & i_mem (7 downto 0);

                        when "101" =>
                            o_reg_data <= (31 downto 16 => '0') & i_mem (15 downto 0);

                        when others =>
                            o_reg_data <= (others => '0');
                    end case;

                when others =>
                    o_reg_addr <= (others => '0');
                    o_reg_data <= (others => '0');
                    o_reg_we <= '0';
            end case;
        end if;
    end process;

end;