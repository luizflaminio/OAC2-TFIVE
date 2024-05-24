library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity top_level is
	port(
		clock, reset: in STD_LOGIC;
		WriteData, DataAdr: out STD_LOGIC_VECTOR(31 downto 0);
 		MemWrite: out STD_LOGIC;
		ReadEnable: out STD_LOGIC
	);

end entity top_level;

architecture test of top_level is
	component pipeline_riscv is
		port(
			clock, reset     	    : in  STD_LOGIC;
			pc 				     	: out STD_LOGIC_VECTOR(31 downto 0);
			instruction 		    : in  STD_LOGIC_VECTOR(31 downto 0);
			MemWrite	     		: out STD_LOGIC;
			ReadEnable 				: out STD_LOGIC;
			ALUResult, WriteData    : out STD_LOGIC_VECTOR(31 downto 0);
			ReadData		        : in  STD_LOGIC_VECTOR(31 downto 0)
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
			read_enable			: in STD_LOGIC;
			addr, data_in       : in STD_LOGIC_VECTOR(31 downto 0);
			data_out            : out STD_LOGIC_VECTOR(31 downto 0)
		);
 	end component;

	signal s_PC                   : STD_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";
	signal s_Instr, s_ReadData    : STD_LOGIC_VECTOR(31 downto 0);

	signal s_ALUResult, s_WriteData : STD_LOGIC_VECTOR(31 downto 0);
	signal s_MemWrite             : STD_LOGIC := '0';
	signal s_ReadEnable 		  : STD_LOGIC := '0';
begin
	-- instantiate processor and memories
	pipeline: pipeline_riscv
		port map(
			clock 		=> clock,
			reset 		=> reset,
			PC    		=> s_pc,
			Instruction => s_instr,
			MemWrite 	=> s_MemWrite,
		    WriteData 	=> s_WriteData,
			ReadEnable	=> s_ReadEnable,
			ALUResult 	=> s_ALUResult,
			ReadData 	=> s_ReadData
		);

 	inst_mem: instruction_memory
		generic map (
			data_file_name => "rom.txt"
		)
		port map(
			addr        => s_pc,
			data		=> s_instr
		);

 	data_mem: data_memory
		port map(
			clock 		 => clock,
			write_enable => s_MemWrite,
			read_enable  => s_ReadEnable,
			addr  		 => s_ALUResult,
			data_in  	 => s_WriteData,
			data_out 	 => s_ReadData
		);

	WriteData <= s_WriteData;
	MemWrite  <= s_MemWrite;
	DataAdr   <= s_ALUResult;
	ReadEnable <= s_ReadEnable;
end;
