library ieee;
use ieee.numeric_bit.all;
use IEEE.math_real.all;

entity datapath_polileg is
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
end entity datapath_polileg;


architecture arch of datapath_polileg is

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
