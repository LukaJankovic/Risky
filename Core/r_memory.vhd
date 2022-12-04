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

        i_mdata : in std_logic_vector (31 downto 0);
        i_ar    : in std_logic_vector (31 downto 0);
        o_ar    : out std_logic_vector (31 downto 0);
        
        o_addr  : out std_logic_vector (31 downto 0);
        o_mdata : out std_logic_vector (31 downto 0);
        o_we    : out std_logic
    );

end entity;

architecture behavior of r_memory is

    alias op        : std_logic_vector (6 downto 0) is i_inst (6 downto 0);
    alias write_opt : std_logic_vector (2 downto 0) is i_inst (14 downto 12);
    alias rs2       : std_logic_vector (4 downto 0) is i_inst (24 downto 20);
    alias rd        : std_logic_vector (4 downto 0) is i_inst (11 downto 7);

    signal ar : std_logic_vector (31 downto 0) := (others => '0');

    signal to_save  : std_logic_vector (31 downto 0);
    signal mdata    : std_logic_vector (31 downto 0);

    signal prev_op      : std_logic_vector (6 downto 0) := (others => '0');
    signal prev_dest    : std_logic_vector (4 downto 0) := (others => '0');

begin

    data_fwd : process (i_inst)
    begin
        if (prev_dest /= "0000" and prev_op /= OP_SB and prev_dest = rs2) then
            to_save <= ar;
        else
            to_save <= i_mdata;
        end if;
    end process;

    mem_request : process (i_inst, i_ar, mdata)
    begin
        case op is
            when OP_LB =>
                o_addr <= i_ar;
                o_mdata <= (others => '0');
                o_we <= '0';
            when OP_SB =>
                o_addr <= i_ar;
                o_mdata <= mdata;
                o_we <= '1';
            when others =>
                o_addr <= (others => '0');
                o_mdata <= (others => '0');
                o_we <= '0';
        end case;
    end process;

    store_format : process (i_inst, to_save)
    begin
        case write_opt is
            when "000" =>
                mdata <= (31 downto 8 => '0') & to_save (7 downto 0);
            when "001" =>
                mdata <= (31 downto 16 => '0') & to_save (15 downto 0);
            when "010" =>
                mdata <= to_save;
            when others =>
                mdata <= (others => '0');
        end case;
    end process;

    inst_fwd : process (clk)
    begin
        if rising_edge (clk) then
            o_inst <= i_inst;
            ar <= i_ar;
        end if;
    end process;

    save_df : process (clk)
    begin
        if rising_edge (clk) then
            prev_dest <= rd;
            prev_op <= op;
        end if;
    end process;

    o_ar <= ar;

end architecture;
