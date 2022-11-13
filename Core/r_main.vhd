library ieee;
use ieee.std_logic_1164.all;

entity r_main is

    port (
        clk     : in std_logic;
        reset   : in std_logic;

        mmem_address    : out std_logic_vector (31 downto 0);
        mmem_read_data  : in std_logic_vector (31 downto 0);
        mmem_write_data : out std_logic_vector (31 downto 0);
        mmem_we         : out std_logic
    );

end r_main;

architecture behavior of r_main is

    component r_reg_file is
        
        port (
            clk :   in std_logic;
            reset : in std_logic;

            i_addr1 : in std_logic_vector (4 downto 0);
            o_data1 : out std_logic_vector (31 downto 0);

            i_addr2 : in std_logic_vector (4 downto 0);
            o_data2 : out std_logic_vector (31 downto 0);

            i_waddr : in std_logic_vector (4 downto 0);
            i_wdata : in std_logic_vector (31 downto 0);
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

    component r_idecode is

        port (
            clk     : in std_logic;
            reset   : in std_logic;

            i_inst  : in std_logic_vector (31 downto 0);

            o_imm   : out std_logic_vector (31 downto 0);
            o_rs1   : out std_logic_vector (4 downto 0);
            o_rs2   : out std_logic_vector (4 downto 0)
        );
    
    end component;
        
    signal reg_file_i_addr1 : std_logic_vector (4 downto 0);
    signal reg_file_o_data1 : std_logic_vector (31 downto 0);
    signal reg_file_i_addr2 : std_logic_vector (4 downto 0);
    signal reg_file_o_data2 : std_logic_vector (31 downto 0);
    signal reg_file_i_wdata : std_logic_vector (31 downto 0);
    signal reg_file_i_waddr : std_logic_vector (4 downto 0);
    signal reg_file_i_we    : std_logic;

    signal ifetch_o_iaddr   : std_logic_vector (31 downto 0);

    signal idecode_i_inst   : std_logic_vector (31 downto 0);
    signal idecode_o_imm    : std_logic_vector (31 downto 0);
    signal idecode_o_rs1    : std_logic_vector (4 downto 0);
    signal idecode_o_rs2    : std_logic_vector (4 downto 0);

begin

    U0 : r_reg_file port map (
        clk     => clk,
        reset   => reset,
        i_addr1 => reg_file_i_addr1,
        o_data1 => reg_file_o_data1,
        i_addr2 => reg_file_i_addr2,
        o_data2 => reg_file_o_data2,
        i_waddr => reg_file_i_waddr,
        i_wdata => reg_file_i_wdata,
        i_we    => reg_file_i_we
    );

    U1 : r_ifetch port map (
        clk     => clk,
        reset   => reset,
        o_iaddr => ifetch_o_iaddr
    );

    U2 : r_idecode port map (
        clk     => clk,
        reset   => reset,
        i_inst  => idecode_i_inst,
        o_imm   => idecode_o_imm,
        o_rs1   => idecode_o_rs1,
        o_rs2   => idecode_o_rs2
    );

    mmem_address <= ifetch_o_iaddr;
    idecode_i_inst <= mmem_read_data;

end architecture;