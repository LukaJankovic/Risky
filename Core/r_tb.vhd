library ieee;
library std;

use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

use std.textio.all;

entity r_tb is
end r_tb;

architecture behavior of r_tb is

    constant W_LENGTH : integer := 32;
    constant MEM_SIZE : integer := 4096; -- Can be increased to 2^32
    constant PROG_FNAME : string := "../Prog/test.hex";

    type memfile is array (0 to MEM_SIZE - 1) of std_logic_vector (7 downto 0);

    impure function read_memfile (fname : string) return memfile is
        file f                  : text open read_mode is fname;
        variable current_line   : line;
        variable loaded_val     : std_logic_vector (31 downto 0);
        variable res            : memfile := (others => (others => '0'));
        variable i              : integer := 0;
    begin
        while not endfile (f) loop
            readline (f, current_line);
            hread (current_line, loaded_val);
            res (i * 4 + 0) := loaded_val (7 downto 0);
            res (i * 4 + 1) := loaded_val (15 downto 8);
            res (i * 4 + 2) := loaded_val (23 downto 16);
            res (i * 4 + 3) := loaded_val (31 downto 24);
            i := i + 1;
        end loop;
        return res;
    end function;

    component r_main is

        port (
            clk     : in std_logic;
            reset   : in std_logic;

            mmem_address    : out std_logic_vector (31 downto 0);
            mmem_read_data  : in std_logic_vector (31 downto 0);
            mmem_write_data : out std_logic_vector (31 downto 0);
            mmem_we         : out std_logic
        );

    end component;

    signal memory : memfile := read_memfile (PROG_FNAME);

    signal clk      : std_logic;
    signal reset    : std_logic := '0';
    
    signal mmem_address     : std_logic_vector (31 downto 0) := (others => '0');
    signal mmem_write_data  : std_logic_vector (31 downto 0) := (others => '0');
    signal mmem_read_data   : std_logic_vector (31 downto 0) := (others => '0');
    signal mmem_we          : std_logic := '0';

    constant PERIOD : time := 8 ns;

begin

    U : r_main port map (
        clk                 => clk,
        reset               => reset,
        mmem_address        => mmem_address,
        mmem_write_data     => mmem_write_data,
        mmem_read_data      => mmem_read_data
    );

    clk_process : process
    begin
        clk <= '0';
        wait for PERIOD / 2;
        clk <= '1';
        wait for PERIOD / 2;
    end process;

    mmem_access : process (clk)
    begin
        if rising_edge (clk) then
            -- TODO: add write memory

            if (to_integer (unsigned (mmem_address)) < MEM_SIZE) then
                mmem_read_data <=   memory (to_integer (unsigned (mmem_address) + 3)) &
                                    memory (to_integer (unsigned (mmem_address) + 2)) &
                                    memory (to_integer (unsigned (mmem_address) + 1)) &
                                    memory (to_integer (unsigned (mmem_address)));
            else
                mmem_read_data <= (others => 'X');
            end if;
        end if;
    end process;

end behavior;