library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity top_level is
	port(
		clk, reset: in STD_LOGIC;
		WriteData, DataAdr: out STD_LOGIC_VECTOR(31 downto 0);
 		MemWrite: out STD_LOGIC
	);

end entity top_level;

architecture test of top_level is
	component riscv
 		port(
			clk, reset           : in STD_LOGIC;
 			PC                   : out STD_LOGIC_VECTOR(31 downto 0);
 			Instr                : in STD_LOGIC_VECTOR(31 downto 0);
			MemWrite             : out STD_LOGIC;
 			ALUResult, WriteData : out STD_LOGIC_VECTOR(31 downto 0);
 			ReadData             : in STD_LOGIC_VECTOR(31 downto 0)
		);
 	end component;

	component instruction_memory is
		generic(
			data_file_name : string  := "rom.txt"
		);
		port(
			addr : in  STD_LOGIC_VECTOR(31 downto 0);
			data : out STD_LOGIC_VECTOR(31 downto 0)
		);
 	end component;

	component data_memory
 		port(
			clock, write_enable : in STD_LOGIC;
			addr, data_in       : in STD_LOGIC_VECTOR(31 downto 0);
			data_out            : out STD_LOGIC_VECTOR(31 downto 0)
		);
 	end component;

	signal PC, Instr, ReadData    : STD_LOGIC_VECTOR(31 downto 0);

	signal s_WriteData, s_DataAdr : STD_LOGIC_VECTOR(31 downto 0);
	signal s_MemWrite             : STD_LOGIC;
begin
	-- instantiate processor and memories
	risc_v: riscv port map(clk, reset, PC, Instr, s_MemWrite, s_DataAdr, s_WriteData, ReadData);
 	inst_mem: instruction_memory generic map ("rom.txt") port map(PC, Instr);
 	data_mem: data_memory port map(clk, s_MemWrite, s_DataAdr, s_WriteData, ReadData);

	WriteData <= s_WriteData;
	AluResult <= s_DataAdr;
	MemWrite  <= s_MemWrite;
end;
