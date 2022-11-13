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

end entity;

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
            o_rs2   : out std_logic_vector (4 downto 0);

            o_alu_op    : out std_logic_vector (2 downto 0);
            o_alu_neg   : out std_logic
        );
    
    end component;

    component r_iexec is

        port (
            clk     : in std_logic;
            reset   : in std_logic;

            i_inst  : in std_logic_vector (31 downto 0);
            o_inst  : out std_logic_vector (31 downto 0);

            i_imm   : in std_logic_vector (31 downto 0);
            i_arg1  : in std_logic_vector (31 downto 0);
            i_arg2  : in std_logic_vector (31 downto 0);

            i_alu_op    : in std_logic_vector (2 downto 0);
            i_alu_neg   : in std_logic;

            o_alu_res   : out std_logic_vector (31 downto 0)
        );

    end component;

    component r_writeback is

        port (
            clk     : in std_logic;
            reset   : in std_logic;

            i_inst  : in std_logic_vector (31 downto 0);

            i_ar    : in std_logic_vector (31 downto 0);

            o_reg_addr  : out std_logic_vector (4 downto 0);
            o_reg_data  : out std_logic_vector (31 downto 0);
            o_reg_we    : out std_logic
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

    signal idecode_i_inst       : std_logic_vector (31 downto 0);
    signal idecode_o_imm        : std_logic_vector (31 downto 0);
    signal idecode_o_rs1        : std_logic_vector (4 downto 0);
    signal idecode_o_rs2        : std_logic_vector (4 downto 0);
    signal idecode_o_alu_op     : std_logic_vector (2 downto 0);
    signal idecode_o_alu_neg    : std_logic;

    signal iexec_i_inst     : std_logic_vector (31 downto 0);
    signal iexec_o_inst     : std_logic_vector (31 downto 0);
    signal iexec_i_imm      : std_logic_vector (31 downto 0);
    signal iexec_i_arg1     : std_logic_vector (31 downto 0);
    signal iexec_i_arg2     : std_logic_vector (31 downto 0);
    signal iexec_i_alu_op   : std_logic_vector (2 downto 0);
    signal iexec_i_alu_neg  : std_logic;
    signal iexec_o_alu_res  : std_logic_vector (31 downto 0);

    signal writeback_i_inst     : std_logic_vector (31 downto 0);
    signal writeback_i_ar       : std_logic_vector (31 downto 0);
    signal writeback_o_reg_addr : std_logic_vector (4 downto 0);
    signal writeback_o_reg_data : std_logic_vector (31 downto 0);
    signal writeback_o_reg_we   : std_logic;

begin

    regs : r_reg_file port map (
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

    fetch : r_ifetch port map (
        clk     => clk,
        reset   => reset,
        o_iaddr => ifetch_o_iaddr
    );

    decode : r_idecode port map (
        clk         => clk,
        reset       => reset,
        i_inst      => idecode_i_inst,
        o_imm       => idecode_o_imm,
        o_rs1       => idecode_o_rs1,
        o_rs2       => idecode_o_rs2,
        o_alu_op    => idecode_o_alu_op,
        o_alu_neg   => idecode_o_alu_neg
    );

    iexec : r_iexec port map (
        clk         => clk,
        reset       => reset,
        i_inst      => iexec_i_inst,
        o_inst      => iexec_o_inst,
        i_imm       => iexec_i_imm,
        i_arg1      => iexec_i_arg1,
        i_arg2      => iexec_i_arg2,
        i_alu_op    => iexec_i_alu_op,
        i_alu_neg   => iexec_i_alu_neg,
        o_alu_res   => iexec_o_alu_res
    );

    writeback : r_writeback port map (
        clk         => clk,
        reset       => reset,
        i_inst      => writeback_i_inst,
        i_ar        => writeback_i_ar,
        o_reg_addr  => writeback_o_reg_addr,
        o_reg_data  => writeback_o_reg_data,
        o_reg_we    => writeback_o_reg_we
    );

    iexec_inst : process (clk)
    begin
        if rising_edge (clk) then
            iexec_i_inst <= idecode_i_inst;
            iexec_i_imm <= idecode_o_imm;
            iexec_i_alu_op <= idecode_o_alu_op;
            iexec_i_alu_neg <= idecode_o_alu_neg;
        end if;
    end process;

    mmem_address <= ifetch_o_iaddr;

    idecode_i_inst <= mmem_read_data;

    reg_file_i_addr1 <= idecode_o_rs1;
    reg_file_i_addr2 <= idecode_o_rs2;

    iexec_i_arg1 <= reg_file_o_data1;
    iexec_i_arg2 <= reg_file_o_data2;

    writeback_i_inst <= iexec_o_inst;
    writeback_i_ar <= iexec_o_alu_res;

    reg_file_i_waddr <= writeback_o_reg_addr;
    reg_file_i_wdata <= writeback_o_reg_data;
    reg_file_i_we <= writeback_o_reg_we;

end architecture;