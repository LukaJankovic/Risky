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

    signal mdata    : std_logic_vector (31 downto 0);

begin

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

    store_format : process (i_inst, i_mdata)
    begin
        case write_opt is
            when "000" =>
                mdata <= (31 downto 8 => '0') & i_mdata (7 downto 0);
            when "001" =>
                mdata <= (31 downto 16 => '0') & i_mdata (15 downto 0);
            when "010" =>
                mdata <= i_mdata;
            when others =>
                mdata <= (others => '0');
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
