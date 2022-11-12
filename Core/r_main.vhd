library ieee;
use ieee.std_logic_1164.all;

entity r_main is

    port (
        clk     : in std_logic;
        reset   : in std_logic;

        mmem_address    : out std_logic_vector (31 downto 0);
        mmem_write_data : out std_logic_vector (31 downto 0);
        mmem_read_data  : in std_logic_vector (31 downto 0)
    );

end r_main;

architecture behavior of r_main is

    component r_reg_file is
        
        port (
            clk :   in std_logic;
            reset : in std_logic;

            i_addr : in std_logic_vector (4 downto 0);
            i_data : in std_logic_vector (31 downto 0);
            o_data : out std_logic_vector (31 downto 0);
            i_we : in std_logic
        );

    end component;

    component r_ifetch is

        port (
            clk     : in std_logic;
            reset   : in std_logic;

            o_iaddr : out std_logic_vector (31 downto 0)
        );

    end component;
    
    signal reg_file_i_addr : std_logic_vector (4 downto 0);
    signal reg_file_i_data : std_logic_vector (31 downto 0);
    signal reg_file_o_data : std_logic_vector (31 downto 0);
    signal reg_file_i_we : std_logic;

    signal ifetch_o_iaddr : std_logic_vector (31 downto 0);
begin

    U0 : r_reg_file port map (
        clk => clk,
        reset => reset,
        i_addr => reg_file_i_addr,
        i_data => reg_file_i_data,
        o_data => reg_file_o_data,
        i_we => reg_file_i_we
    );

    U1 : r_ifetch port map (
        clk => clk,
        reset => reset,
        o_iaddr => ifetch_o_iaddr
    );

    mmem_address <= ifetch_o_iaddr;

end architecture;