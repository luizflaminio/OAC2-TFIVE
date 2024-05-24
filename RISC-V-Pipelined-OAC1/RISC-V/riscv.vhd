library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity riscv is
	port(
		clk, reset 		     : in STD_LOGIC;
 		PC 				     : out STD_LOGIC_VECTOR(31 downto 0);
 		Instr 				 : in STD_LOGIC_VECTOR(31 downto 0);
 		MemWrite			 : out STD_LOGIC;
 		ALUResult, WriteData : out STD_LOGIC_VECTOR(31 downto 0);
 		ReadData		     : in STD_LOGIC_VECTOR(31 downto 0)
	);
end;

architecture struct of riscv is
	component controller
		port(
			op             : in STD_LOGIC_VECTOR(6 downto 0);
 			funct3         : in STD_LOGIC_VECTOR(2 downto 0);
 			funct7b5, Zero : in STD_LOGIC;
 			ResultSrc      : out STD_LOGIC_VECTOR(1 downto 0);
 			MemWrite       : out STD_LOGIC;
 			PCSrc, ALUSrc  : out STD_LOGIC;
 			RegWrite, Jump : out STD_LOGIC;
 			ImmSrc         : out STD_LOGIC_VECTOR(1 downto 0);
 			ALUControl     : out STD_LOGIC_VECTOR(2 downto 0)
		);
 end component;

	component datapath
		port(
			clk, reset           : in STD_LOGIC;
 			ResultSrc            : in STD_LOGIC_VECTOR(1 downto 0);
 			PCSrc, ALUSrc        : in STD_LOGIC;
 			RegWrite             : in STD_LOGIC;
 			ImmSrc               : in STD_LOGIC_VECTOR(1 downto 0);
 			ALUControl           : in STD_LOGIC_VECTOR(2 downto 0);
 			Zero                 : out STD_LOGIC;
 			PC                   : out STD_LOGIC_VECTOR(31 downto 0);
 			Instr                : in STD_LOGIC_VECTOR(31 downto 0);
 			ALUResult, WriteData : out STD_LOGIC_VECTOR(31 downto 0);
 			ReadData             : in STD_LOGIC_VECTOR(31 downto 0)
		);
 end component;

	signal ALUSrc, RegWrite, Jump, Zero, PCSrc : STD_LOGIC;
	signal ResultSrc, ImmSrc                   : STD_LOGIC_VECTOR(1 downto 0);
 	signal ALUControl                          : STD_LOGIC_VECTOR(2 downto 0) := "000";

begin

 	control: controller port map(Instr(6 downto 0), Instr(14 downto 12),
 															Instr(30), Zero, ResultSrc, MemWrite,
 															PCSrc, ALUSrc, RegWrite, Jump,
 															ImmSrc, ALUControl);
 	dp: datapath port map(clk, reset, ResultSrc, PCSrc, ALUSrc,
 											 RegWrite, ImmSrc, ALUControl, Zero,
 											 PC, Instr, ALUResult,WriteData, ReadData);
end;
