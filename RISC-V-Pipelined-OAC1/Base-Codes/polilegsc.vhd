-- NUSP: 12550991
-- joao.arroyo@usp.br
-- 22/06/2022

---- Componentes utilizados ----
--------------------------------

--- Shift left 2 ---

library ieee;
use ieee.numeric_bit.all;

entity shiftleft2 is
	generic (
		ws : natural := 64);
	port(
		i : in  bit_vector (ws-1 downto 0);
		o : out bit_vector (ws-1 downto 0)
	);
end entity shiftleft2;

architecture shiftleft2_arch of shiftleft2 is

begin
	o <=  i(ws-3 downto 0)&"00";
end architecture shiftleft2_arch;

--- Sign Extend ---

library ieee;
use ieee.numeric_bit.all;

entity signExtend is
	port(
		i : in  bit_vector (31 downto 0);
		o : out bit_vector (63 downto 0)
	);
end signExtend;

architecture sign_Extend_arch of signExtend is

	signal   D_address     : bit_vector(8 downto 0);
	signal   CBZ_address   : bit_vector(18 downto 0);
	signal   B_address     : bit_vector(25 downto 0);
	signal   D_extended    : bit_vector(54 downto 0);
	signal   CBZ_extended  : bit_vector(44 downto 0);
	signal   B_extended    : bit_vector(37 downto 0);

begin

    D_address   <= i(20 downto 12);
    CBZ_address <= i(23 downto 5);
    B_address   <= i(25 downto 0);

	D_ext:	for J in 54 downto 0 generate
		D_extended(J) <= D_address(8);
	end generate;

	CBZ_ext:  for J in 44 downto 0 generate
		CBZ_extended(J) <= CBZ_address(18);
	end generate;

	B_ext:	for J in 37 downto 0 generate
		B_extended(J) <= B_address(25);
	end generate;

	o <= (D_extended & D_address)     when i(31 downto 21) = "11111000000" else
		 (D_extended & D_address)     when i(31 downto 21) = "11111000010" else
		 (CBZ_extended & CBZ_address) when i(31 downto 24) = "10110100"    else
		 (B_extended & B_address);

end architecture sign_Extend_arch;

--- Register File ---

library ieee;
use ieee.numeric_bit.all;
use IEEE.math_real.all;


entity regfile is
	generic(
		reg_n  : natural := 10;
		word_s : natural := 64
	);
	port(
		clock        : in  bit;
		reset        : in  bit;
		regWrite     : in  bit;
		rr1, rr2, wr : in  bit_vector (natural(ceil(log2(real(reg_n ))))-1 downto 0);
		d            : in  bit_vector (word_s-1 downto 0);
		q1, q2       : out bit_vector (word_s-1 downto 0)
	);
end regfile;

architecture regFile_arch of regfile is

	type reg_File is array (0 to reg_n-1) of bit_vector(word_s-1 downto 0);

	signal   reg_FileAT4 : reg_File;
	constant null_vector : bit_vector(word_s-1 downto 0) := (others => '0');
begin

	reg_write: process (clock, reset) is
	begin
		if reset = '1' then
			Registradores: for I in 0 to reg_n-2 loop
				reg_FileAT4(I) <= null_vector;
			end loop;

		elsif rising_edge(clock) then
			if regWrite = '1' then
				if  to_integer(unsigned(wr)) < reg_n -1 then
					reg_FileAT4(to_integer(unsigned(wr))) <= d;
				end if;
			end if;
		end if;
	end process;

	q1 <= null_vector when to_integer(unsigned(rr1)) = reg_n-1 else
		  reg_FileAT4(to_integer(unsigned(rr1)));
	q2 <= null_vector when to_integer(unsigned(rr2)) = reg_n-1 else
		  reg_FileAT4(to_integer(unsigned(rr2)));

end architecture regFile_arch;

--- ALU completa ---

library ieee;
use ieee.numeric_bit.all;

entity alu is
	generic(
		size : natural := 4);
	port(
		A, B : in  bit_vector (size-1 downto 0);
		F    : out bit_vector (size-1 downto 0);
		S    : in  bit_vector (3 downto 0);
		Z    : out bit;
		Ov   : out bit;
		Co   : out bit
	);
end entity alu;

architecture arch_ula of alu is

	signal A_and_B    : bit_vector (size-1 downto 0);
	signal A_or_B     : bit_vector (size-1 downto 0);
	signal A_Add_B    : bit_vector (size-1 downto 0);
	signal A_SLT_B    : bit_vector (size-1 downto 0);
	signal A_ready    : bit_vector (size-1 downto 0);
	signal B_ready    : bit_vector (size-1 downto 0);
	signal Carry      : bit_vector (size downto 0);
	signal Ov_copy    : bit;
	signal nullVector : bit_vector (size-1 downto 0) := (others => '0');
	signal zeroADD    : bit_vector (size downto 0)   := (others => '0');
	signal zeroAND    : bit_vector (size downto 0)   := (others => '0');
	signal zeroOR     : bit_vector (size downto 0)   := (others => '0');

begin
-- Valores de A, B e carry usados no FullAdder e portas lógicas.
	Carry(0) <= S(2);

	with S(3) select
	A_ready <= A   when '0',
			not(A) when '1',
			nullVector when others;

	with S(2) select
	B_ready <= B   when '0',
			not(B) when '1',
			nullVector when others;

	-- Gerar resultado:
	F <=   A_Add_B  when S = "0010" or S = "0110" else
		   A_and_B   when S = "0000" or S = "1100" else
		   A_or_B    when S = "0001" 			   else
		   A_SLT_B   when S = "0111";

	-- Primeira operação:
	AND_BITaBIT : for I in size-1 downto 0 generate
		A_and_B(I) <= A_ready(I) and B_ready(I);
	end generate;

		-- Segunda operação:
	OR_BITaBIT : for I in size-1 downto 0 generate
		A_or_B(I) <= A(I) or B(I);
	end generate;

	-- Terceira operação:
	ADDITION : for I in size-1 downto 0 generate
		A_Add_B(I) <= A_ready(I) xor B_ready(I) xor Carry(I);
		Carry(I+1) <= (B_ready(I) and Carry(I)) or (Carry(I) and A_ready(I)) or (A_ready(I) and B_ready(I));
	end generate;

	-- Quinta operação:
	A_SLT_B(size-1 downto 1) <= nullVector(size-1 downto 1);

	with Ov_copy select
	A_SLT_B(0) <= A_ready(size-1) and B_ready(size-1)  when '1',
				  A_Add_B(size-1)              when others;

	-- Zero flag:
	with S select
	Z <= not(zeroAND(size)) when "0000",
		 not(zeroOR(size))  when "0001",
		 not(zeroADD(size)) when "0010",
		 not(zeroADD(size)) when "0110",
		 not(A_SLT_B(0))    when "0111",
		 not(zeroAND(size)) when "1100",
			       	'0'	   when others;

	Zero_1: for I in size-1 downto 0 generate
		zeroAND(I+1) <= zeroAND(I) or (A_and_B(I));
	end generate;

	Zero_2: for I in size-1 downto 0 generate
		zeroOR(I+1) <= zeroOR(I) or (A_or_B(I));
	end generate;

	Zero_3: for I in size-1 downto 0 generate
		zeroADD(I+1) <= zeroADD(I) or (A_Add_B(I));
	end generate;

	-- Overflow:
	Ov_copy <= ( (not A_ready(size-1)) and (not B_ready(size-1)) and  A_Add_B(size-1)       ) or ( A_ready(size-1)  and B_ready(size-1) and (not A_Add_B(size-1))     );
	Ov <= Ov_copy;
	-- Carry:
	Co <= Carry(size);
end architecture;

--- Register ---
library ieee;
use ieee.numeric_bit.all;

entity d_register is
	generic(
		width : natural := 64
	);
	port(
		clock : in bit;
		reset : in bit;
		load  : in bit;
		d     : in bit_vector(width-1 downto 0);
		q     : out bit_vector(width-1 downto 0)
	);
end entity d_register;

architecture d_register_arch of d_register is

	signal q_auxiliar   : bit_vector(width-1 downto 0);

	begin

		process( clock, reset ) begin
			if(reset = '1') then
				q_auxiliar <=  (others => '0');
			elsif(rising_edge(clock)) then
				if(load = '1') then
					q_auxiliar <= d;
				end if;
			end if;
		end process;

		q <= q_auxiliar;

end architecture d_register_arch;

--- controlunit ---

library ieee;
use ieee.numeric_bit.all;

entity controlunit is
	port(
		reg2loc 	 : out bit;
		uncondBranch : out bit;
		branch 		 : out bit;
		memRead 	 : out bit;
		memToReg 	 : out bit;
		aluOp 		 : out bit_vector (1 downto 0);
		memWrite 	 : out bit;
		aluSrc 		 : out bit;
		regWrite 	 : out bit;

		opcode : in bit_vector (10 downto 0)
	);
end entity controlunit;


architecture arch of controlunit is

	signal R        : bit;
	signal LDUR     : bit;
	signal STUR     : bit;
	signal CBZ      : bit;
	signal B        : bit;

begin

	-- Determinar a instrucao

	R <= opcode(10) and (not opcode(7)) and opcode(6) and (not opcode(5)) and opcode(4)
			and (not opcode(2))and (not opcode(1)) and (not opcode(0));

	LDUR <= opcode(10) and opcode(9) and opcode(8) and opcode(7) and opcode(6) and (not opcode(5))
			and (not opcode(4)) and (not opcode(3)) and (not opcode(2)) and opcode(1) and (not opcode(0));

	STUR <= opcode(10) and opcode(9) and opcode(8) and opcode(7) and opcode(6) and ( not opcode(5))
			and ( not opcode(4)) and ( not opcode(3)) and ( not opcode(2)) and ( not opcode(1)) and (not opcode(0));

	CBZ <= opcode(10) and ( not opcode(9)) and opcode(8) and opcode(7) and (not opcode(6)) and opcode(5)
			and ( not opcode(4)) and ( not opcode(3));

	B <= not opcode(10) and ( not opcode(9)) and ( not opcode(8)) and opcode(7)
			and ( not opcode(6)) and opcode(5);

	-- Sinais de controle

	reg2loc <=  STUR or CBZ or B;
	aluSrc <= LDUR or STUR;
	memToReg <= LDUR;
	regWrite <= R or LDUR;
	memRead <= LDUR;
	memWrite <= STUR;
	branch <= CBZ or B;
	uncondBranch <= B;

	aluOp(0) <= CBZ or B;
	aluOp(1) <= R;

end architecture;

--- datapath ---

library ieee;
use ieee.numeric_bit.all;
use IEEE.math_real.all;

entity datapath is
	port(
		clock : in bit;
		reset : in bit;

		reg2loc  : in bit;
		pcsrc 	 : in bit;
		memToReg : in bit;
		aluCtrl  : in bit_vector (3 downto 0);
		aluSrc   : in bit;
		regWrite : in bit;

		opcode : out bit_vector (10 downto 0);
		zero   : out bit;

		imAddr : out bit_vector (63 downto 0);
		imOut  : in bit_vector (31 downto 0);

		dmAddr : out bit_vector (63 downto 0);
		dmIn : out bit_vector (63 downto 0);
		dmOut : in bit_vector (63 downto 0)
	);
end entity datapath;


architecture arch of datapath is

-- Declaracao dos componentes.
	component shiftleft2 is
		generic (
			ws : natural := 64);
		port(
			i : in  bit_vector (ws-1 downto 0);
			o : out bit_vector (ws-1 downto 0)
		);
	end component shiftleft2;

	component signExtend is
		port(
		i : in  bit_vector (31 downto 0);
		o : out bit_vector (63 downto 0)
		);
	end component signExtend;

	component alu is
		generic(
			size : natural := 4);
		port(
			A, B : in  bit_vector (size-1 downto 0);
			F    : out bit_vector (size-1 downto 0);
			S    : in  bit_vector (3 downto 0);
			Z    : out bit;
			Ov   : out bit;
			Co   : out bit
		);
	end component alu;

	component regfile is
		generic(
			reg_n  : natural := 10;
			word_s : natural := 64
		);
		port(
			clock        : in  bit;
			reset        : in  bit;
			regWrite     : in  bit;
			rr1, rr2, wr : in  bit_vector (natural(ceil(log2(real(reg_n ))))-1 downto 0);
			d            : in  bit_vector (word_s-1 downto 0);
			q1, q2       : out bit_vector (word_s-1 downto 0)
		);
	end component regfile;

	component d_register is
		generic(
			width : natural := 64
		);
		port(
			clock : in bit;
			reset : in bit;
			load  : in bit;
			d     : in bit_vector(width-1 downto 0);
			q 	  : out bit_vector(width-1 downto 0)
		);
	end component d_register;



-- Sinais intermediarios necessarios.

-- PC --
	signal pc_in, pc_out       : bit_vector(63 downto 0) := (others => '0');
-- PC_adder --
	signal pc_adder_out        : bit_vector(63 downto 0) := (others => '0');
	constant four_bit_vector   : bit_vector(63 downto 0) := (2 => '1', others => '0');
-- PC branch adder --
	signal pc_branch_adder_out : bit_vector(63 downto 0) := (others => '0');
-- Instruction memory --
	signal instruction         : bit_vector(31 downto 0) := (others => '0');
-- Sign extend --
	signal extended_immediate  : bit_vector(63 downto 0) := (others => '0');
-- shift left 2 --
	signal shifted_immediate   : bit_vector(63 downto 0) := (others => '0');
-- Register file --
	signal reg1_address        : bit_vector(4 downto 0) := (others => '0');
	signal reg2_address        : bit_vector(4 downto 0) := (others => '0');
	signal regwrite_address    : bit_vector(4 downto 0) := (others => '0');
	signal write_data          : bit_vector(63 downto 0) := (others => '0');
	signal data_reg1           : bit_vector(63 downto 0) := (others => '0');
	signal data_reg2           : bit_vector(63 downto 0) := (others => '0');
-- mux register 2 --
	signal reg2_mux0           : bit_vector(4 downto 0)  := (others => '0');
-- main ALU --
	signal data2_in_alu            : bit_vector(63 downto 0) := (others => '0');
	signal alu_out             : bit_vector(63 downto 0) := (others => '0');

begin
-- Atribuicoes

	instruction <= imOut;
	imAddr <= pc_out;

	opcode <= ("10110100000") when instruction(31 downto 24) = "10110100" else -- CBZ
			  ("00010100000") when instruction(31 downto 26) = "000101" else -- B
			  instruction(31 downto 21); -- LDUR, STUR and R_type.

	reg1_address <= instruction(9 downto 5);
	reg2_mux0 <= instruction(20 downto 16);
	regwrite_address <= instruction(4 downto 0);

	dmAddr <= alu_out;
	dmIn <= data_reg2;

-- Instanciacao dos componentes
	PC_register : d_register
		generic map(64) port map(clock, reset, '1', pc_in, pc_out);

	PC_adder : alu
		generic map(64) port map(pc_out, four_bit_vector, pc_adder_out, "0010", open, open, open);

	PC_branch_adder : alu
		generic map(64) port map(pc_out, shifted_immediate, pc_branch_adder_out, "0010", open, open, open);

	sign_Extend : signExtend
		port map(instruction, extended_immediate);

	logic_shift_left_2 : shiftleft2
		generic map(64) port map(extended_immediate, shifted_immediate);

	registerFile : regfile
		generic map(32, 64) port map(clock, reset, regWrite, reg1_address, reg2_address, regwrite_address, write_data, data_reg1, data_reg2);

	main_alu  : alu
		generic map(64) port map(data_reg1, data2_in_alu, alu_out, aluCtrl, zero, open, open);

-- Mux
	with reg2loc select
		reg2_address <= reg2_mux0        when '0',
						regwrite_address when '1',
						(others => '0')  when others;

	with aluSrc select
		data2_in_alu <= data_reg2 when '0',
					    extended_immediate when '1',
					    (others => '0') when others;

	with pcsrc select
		pc_in <= pc_adder_out when '0',
				 pc_branch_adder_out when '1',
				 (others => '0') when others;

	with memToReg select
		write_data <= dmOut when '1',
					  alu_out when '0',
					  (others => '0') when others;


end architecture arch;

--- POLILEG ---

library ieee;
use ieee.numeric_bit.ALL;
use ieee.math_real.ALL;

entity polilegsc is
	port (
		clock, reset: in bit;

		dmem_addr : out bit_vector(63 downto 0);
		dmem_dati : out bit_vector(63 downto 0);
		dmem_dato : in  bit_vector(63 downto 0);
		dmem_we   : out bit;

		imem_addr : out bit_vector(63 downto 0);
		imem_data : in  bit_vector(31 downto 0)
	);
end entity polilegsc;

architecture polilegsc_arch of polilegsc is

	component datapath is
		port(

			clock: in bit;
			reset: in bit;

			reg2loc  : in bit;
			pcsrc    : in bit;
			memToReg : in bit;
			aluCtrl  : in bit_vector(3 downto 0);
			aluSrc   : in bit;
			regWrite : in bit;

			opcode   : out bit_vector(10 downto 0);
			zero     : out bit;

			imAddr   : out bit_vector(63 downto 0);
			imOut    : in bit_vector(31 downto 0);

			dmAddr   : out bit_vector(63 downto 0);
			dmIn     : out bit_vector(63 downto 0);
			dmOut    : in bit_vector(63 downto 0)
		);
	end component datapath;

	component controlunit is
		port(
			reg2loc      : out bit;
			uncondbranch : out bit;
			branch       : out bit;
			memRead      : out bit;
			memToReg     : out bit;
			aluOp        : out bit_vector(1 downto 0);
			memWrite     : out bit;
			aluSrc       : out bit;
			regWrite     : out bit;
			opcode       : in bit_vector(10 downto 0)
		);
	end component controlunit;


	signal opcode: 		    bit_vector(10 downto 0);
	signal reg2loc: 		bit := '0';
	signal uncondBranch: 	bit := '0';
	signal branch: 		bit := '0';
	signal memRead: 		bit := '0';
	signal memToReg: 		bit := '0';
	signal aluOp: 		bit_vector(1 downto 0) := (others => '0');
	signal memWrite: 		bit := '0';
	signal aluSrc: 		bit := '0';
	signal regWrite: 		bit := '0';

	signal aluCtrl: 		bit_vector(3 downto 0) := (others => '0');

	signal pcsrc: 		bit := '0';
	signal zero: 			bit := '0';

	begin
		dmem_we <= 	memWrite;

		pcsrc <= uncondBranch or (branch and zero);

		Instance_DF: datapath
			port map(clock, reset, reg2loc, pcsrc, memtoreg, aluctrl,
			         alusrc, regwrite, opcode, zero, imem_addr, imem_data, dmem_addr, dmem_dati, dmem_dato);

		Instance_UC: controlunit
			port map(reg2loc, uncondBranch, branch, memRead, memToReg, aluOp, memWrite, aluSrc, regWrite, opcode);


		aluCtrl <= "0010" when aluOp = "00" else
					"0111" when aluOp = "01" else
					"0010" when opcode = "10001011000" else
					"0110" when opcode = "11001011000" else
					"0000" when opcode = "10001010000" else
					"0001" when opcode = "10101010000";

end architecture polilegsc_arch;
