---------- Based on H&H

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;

entity datapath is
	port(
		clk, reset     	     : in STD_LOGIC;
 		ResultSrc      	     : in STD_LOGIC_VECTOR(1 downto 0);
 		PCSrc, ALUSrc  	     : in STD_LOGIC;
 		RegWrite       	     : in STD_LOGIC;
 		ImmSrc         	     : in STD_LOGIC_VECTOR(1 downto 0);
 		ALUControl     	     : in STD_LOGIC_VECTOR(2 downto 0);
 		Zero           	     : out STD_LOGIC;
 		PC             		 : out STD_LOGIC_VECTOR(31 downto 0);
 		Instr      	      	 : in STD_LOGIC_VECTOR(31 downto 0);
 		ALUResult, WriteData : out STD_LOGIC_VECTOR(31 downto 0);
 		ReadData             : in STD_LOGIC_VECTOR(31 downto 0)
	);
end entity datapath;


architecture struct of datapath is

	component flopr is
 		generic(
			width: integer
		);
 		port(
			clk, reset : in STD_LOGIC;
 			d          : in STD_LOGIC_VECTOR(width-1 downto 0);
 			q          : out STD_LOGIC_VECTOR(width-1 downto 0)
		);
 end component;

 component adder is
	port (
	  A, B      : in  STD_LOGIC_VECTOR(31 downto 0);
	  Sum       : out STD_LOGIC_VECTOR(31 downto 0)
	);
  end component;

component mux2 is
	generic(
		width: integer
	);
	port(
		d0, d1 : in STD_LOGIC_VECTOR(width-1 downto 0);
 		s      : in STD_LOGIC;
 		y      : out STD_LOGIC_VECTOR(width-1 downto 0)
	);
 end component;

 component mux3 is
	generic(
		width: integer := 8
	);
	port(
		d0, d1, d2 : in std_logic_vector(width-1 downto 0);
 		s 		   : in std_logic_vector(1 downto 0);
 		y		   : out std_logic_vector(width-1 downto 0)
	);
end component;

component regfile is
	generic(
		reg_n  : natural := 32;
		word_s : natural := 32
	);
	port(
		clock        : in STD_LOGIC;
		reset        : in  std_logic;
		regWrite     : in  std_logic;
 		rr1, rr2, wr : in  std_logic_vector (natural(ceil(log2(real(reg_n ))))-1 downto 0);
 		d            : in  std_logic_vector (word_s-1 downto 0);
		q1, q2       : out std_logic_vector (word_s-1 downto 0)
	);
end component;

component extend is
	port(
		instruction : in std_logic_vector(31 downto 7);
		imm_source  : in std_logic_vector(1 downto 0);
		imm_out		: out std_logic_vector(31 downto 0)
	);
 end component;

 component alu is
	generic(
		size : natural := 4);
	port(
		A, B : in  std_logic_vector (size-1 downto 0);
		F    : out std_logic_vector (size-1 downto 0);
		S    : in  std_logic_vector (2 downto 0);
		Z    : out std_logic;
		Ov   : out std_logic;
		Co   : out std_logic
	);
end component alu;


 signal PCNext, PCPlus4, PCTarget      : STD_LOGIC_VECTOR(31 downto 0);
 signal ImmExt                         : STD_LOGIC_VECTOR(31 downto 0);
 signal SrcA, SrcB                     : STD_LOGIC_VECTOR(31 downto 0);
 signal Result                         : STD_LOGIC_VECTOR(31 downto 0);
 signal s_pc, s_WriteData, s_ALUResult : std_logic_vector(31 downto 0);
 signal s_reset                        : std_logic := '0';

begin
 -- next PC logic
 pcreg: flopr generic map(32) port map(clk, reset, PCNext, s_pc);

 pcadd4: adder port map(s_pc, X"00000004", PCPlus4);
 pcaddbranch: adder port map(s_pc, ImmExt, PCTarget); -- Calculate target
 pcmux: mux2 generic map(32) port map(PCPlus4, PCTarget, PCSrc, PCNext); -- MUX logic.
 PC <= s_pc;

 -- register file logic
 rf: regfile
 	generic map(32, 32)
	port map(
		clock => clk,
		reset => s_reset,
		regWrite => RegWrite,
		rr1 => Instr(19 downto 15),
		rr2 => Instr(24 downto 20),
		wr => Instr(11 downto 7),
		d =>  Result,
		q1 => SrcA,
		q2 =>  s_WriteData
	);

 ext: extend port map(Instr(31 downto 7), ImmSrc, ImmExt);

 -- ALU logic
 srcbmux: mux2 generic map(32) port map(s_WriteData, ImmExt, ALUSrc, SrcB);
 WriteData <= s_WriteData;

 mainalu: alu generic map(32) port map(SrcA, SrcB, s_ALUResult, ALUControl, Zero, open, open);

 resultmux: mux3 generic map(32) port map(s_ALUResult, ReadData, PCPlus4, ResultSrc, Result);
 ALUResult <= s_ALUResult;
end;
