library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;

entity pipeline_riscv is
	port(
		clock, reset     	    : in  STD_LOGIC;
		-- Instruction Memory
		pc 				     	: out STD_LOGIC_VECTOR(31 downto 0);
		instruction 		    : in  STD_LOGIC_VECTOR(31 downto 0);
		-- Data Memory
		MemWrite	     		: out STD_LOGIC;
		ReadEnable 				: out STD_LOGIC;
		ALUResult, WriteData    : out STD_LOGIC_VECTOR(31 downto 0);
		ReadData		        : in  STD_LOGIC_VECTOR(31 downto 0)
	);
end entity pipeline_riscv;


architecture struct of pipeline_riscv is


	component hazard_unit is
		port(
			reg_source_id1 : in std_logic_vector(4 downto 0);
			reg_source_id2 : in std_logic_vector(4 downto 0);
			reg_destin_ex  : in std_logic_vector(4 downto 0);
			result_src_ex  : in std_logic;
			pc_src_ex      : in std_logic;
			reg_source_ex1 : in std_logic_vector(4 downto 0);
			reg_source_ex2 : in std_logic_vector(4 downto 0);
			reg_destin_mm  : in std_logic_vector(4 downto 0);
			reg_destin_wb  : in std_logic_vector(4 downto 0);
			reg_write_mm   : in std_logic;
			reg_write_wb   : in std_logic;
			stall_if       : out std_logic;
			stall_id       : out std_logic;
			flush_id       : out std_logic;
			flush_ex       : out std_logic;
			alu_op1        : out std_logic_vector(1 downto 0);
			alu_op2        : out std_logic_vector(1 downto 0)
		);
	end component;

	component stage_f is
		port(
			clock       : in std_logic;
			reset		: in std_logic;
			pc_src_e    : in  std_logic;
			stall_f     : in  std_logic;
			target_addr : in  std_logic_vector(31 downto 0);
			pc_out      : out std_logic_vector(31 downto 0);
			pc_plus_4   : out std_logic_vector(31 downto 0)
		);
	end component;

	component pipe_regF is
		port (
			clk    : in std_logic;
			reset  : in std_logic;
			enable : in std_logic;
			PCF_in : in std_logic_vector(31 downto 0);
			PCPlus4F_in: in std_logic_vector(31 downto 0);
			InstrF_in : in std_logic_vector(31 downto 0);
			PCD_out : out std_logic_vector(31 downto 0);
			PCPlus4D_out : out std_logic_vector(31 downto 0);
			InstrD_out : out std_logic_vector(31 downto 0)
		);
	end component;

	component stage_d is
		port(
			clock           : in  std_logic;
			reset           : in std_logic;
			instruction     : in  std_logic_vector(31 downto 0);
			reg_write_w     : in  std_logic;
			addr_reg_write  : in  std_logic_vector(4 downto 0);
			data_reg_in     : in  std_logic_vector(31 downto 0);
			data_reg_src1   : out std_logic_vector(31 downto 0);
			data_reg_src2   : out std_logic_vector(31 downto 0);
			imm_ext_d_out   : out std_logic_vector(31 downto 0);
			reg_write_d     : out std_logic;
			result_src_d    : out std_logic_vector(1 downto 0);
			mem_write_d     : out std_logic;
			jump_d          : out std_logic;
			branch_d        : out std_logic;
			alu_control_d   : out std_logic_vector(2 downto 0);
			alu_src_d       : out std_logic
		);
	end component;

	component pipe_regD is
		port (
			clk    : in std_logic;
			reset  : in std_logic;
			enable : in std_logic;
			RegWriteD_in : in std_logic;
			ResultSrcD_in : in std_logic_vector(1 downto 0);
			MemWriteD_in : in std_logic;
			JumpD_in : in std_logic;
			BranchD_in : in std_logic;
			ALUControlD_in : in std_logic_vector(2 downto 0);
			ALUSrcD_in : in std_logic;
			RD1D_in : in std_logic_vector(31 downto 0);
			RD2D_in : in std_logic_vector(31 downto 0);
			PCD_in : in std_logic_vector(31 downto 0);
			Rs1D_in : in std_logic_vector(4 downto 0);
			Rs2D_in : in std_logic_vector(4 downto 0);
			RdD_in : in std_logic_vector(4 downto 0);
			ImmExtD_in : in std_logic_vector(31 downto 0);
			PCPlus4D_in: in std_logic_vector(31 downto 0);
			RegWriteE_out : out std_logic;
			ResultSrcE_out : out std_logic_vector(1 downto 0);
			MemWriteE_out : out std_logic;
			JumpE_out : out std_logic;
			BranchE_out : out std_logic;
			ALUControlE_out : out std_logic_vector(2 downto 0);
			ALUSrcE_out : out std_logic;
			RD1E_out : out std_logic_vector(31 downto 0);
			RD2E_out : out std_logic_vector(31 downto 0);
			PCE_out : out std_logic_vector(31 downto 0);
			Rs1E_out : out std_logic_vector(4 downto 0);
			Rs2E_out : out std_logic_vector(4 downto 0);
			RdE_out : out std_logic_vector(4 downto 0);
			ImmExtE_out : out std_logic_vector(31 downto 0);
			PCPlus4E_out: out std_logic_vector(31 downto 0)
		);
	end component;

	component stage_e is
		port(
			clock          : in  std_logic;
			reset          : in  std_logic;
			data_reg_s1_e  : in std_logic_vector(31 downto 0);
			data_reg_s2_e  : in std_logic_vector(31 downto 0);
			pc_e           : in std_logic_vector(31 downto 0);
			imm_ext_e      : in std_logic_vector(31 downto 0);
			alu_control_e  : in std_logic_vector(2 downto 0);
			alu_src_e      : in std_logic;
			alu_result_m   : in std_logic_vector(31 downto 0);
			result_w       : in std_logic_vector(31 downto 0);
			forwarding_a_e : in std_logic_vector(1 downto 0);
			forwarding_b_e : in std_logic_vector(1 downto 0);
			alu_result_e   : out std_logic_vector(31 downto 0);
			write_data_e   : out  std_logic_vector(31 downto 0);
			pc_target_e    : out  std_logic_vector(31 downto 0);
			zero_e         : out std_logic

		);
	end component;

	component pipe_regE is
		port (
			clk    : in std_logic;
			reset  : in std_logic;
			enable : in std_logic;
			RegWriteE_in : in std_logic;
			ResultSrcE_in : in std_logic_vector(1 downto 0);
			MemWriteE_in : in std_logic;
			ALUResultE_in : in std_logic_vector(31 downto 0);
			WriteDataE_in : in std_logic_vector(31 downto 0);
			RdE_in : in std_logic_vector(4 downto 0);
			PCPlus4E_in: in std_logic_vector(31 downto 0);
			RegWriteM_out : out std_logic;
			ResultSrcM_out : out std_logic_vector(1 downto 0);
			MemWriteM_out : out std_logic;
			ALUResultM_out : out std_logic_vector(31 downto 0);
			WriteDataM_out : out std_logic_vector(31 downto 0);
			RdM_out : out std_logic_vector(4 downto 0);
			PCPlus4M_out: out std_logic_vector(31 downto 0)
		);
	end component;

	component pipe_regM is
		port (
			clk    : in std_logic;
			reset  : in std_logic;
			enable : in std_logic;
			RegWriteM_in : in std_logic;
			ResultSrcM_in : in std_logic_vector(1 downto 0);
			ALUResultM_in : in std_logic_vector(31 downto 0);
			ReadDataM_in : in std_logic_vector(31 downto 0);
			RdM_in : in std_logic_vector(4 downto 0);
			PCPlus4M_in : in std_logic_vector(31 downto 0);
			RegWriteW_out : out std_logic;
			ResultSrcW_out : out std_logic_vector(1 downto 0);
			ALUResultW_out : out std_logic_vector(31 downto 0);
			ReadDataW_out : out std_logic_vector(31 downto 0);
			RdW_out : out std_logic_vector(4 downto 0);
			PCPlus4W_out : out std_logic_vector(31 downto 0)
		);
	end component;

	component stage_w is
		port(
			clock            : in std_logic;
			reset            : in std_logic;
			read_data_w      : in  std_logic_vector(31 downto 0);
			pc_plus_4_w      : in std_logic_vector(31 downto 0);
			alu_result_m_out : in std_logic_vector(31 downto 0);
			result_src_w     : in std_logic_vector(1 downto 0);
			result_w         : out std_logic_vector(31 downto 0)
		);
	end component;



	-- Stage F signals.
	signal s_pc_f 		   : std_logic_vector(31 downto 0) := "00000000000000000000000000000000"; -- Saida PC do StageF
	signal s_pc_src_e 	   : std_logic; -- Sai do EXE (zero bool logic)
	signal s_stall_f  	   : std_logic; -- Sai da Hazard
	signal s_pc_target_e   : std_logic_vector(31 downto 0); -- Sai do EXE
	signal s_pc_plus_4     : std_logic_vector(31 downto 0); -- Sai do F

	-- IF/ID regs
	signal s_flush_d       : std_logic; -- Sai da Hazard
	signal s_reset_f_regs  : std_logic; -- Input F regs
	signal s_stall_d       : std_logic; -- Output Hazard Unit
	signal s_enable_f_regs : std_logic; -- Input F regs
	signal s_pc_d		   : std_logic_vector(31 downto 0);
	signal s_pc_plus_4_d   : std_logic_vector(31 downto 0);
	signal s_instruction_d : std_logic_vector(31 downto 0);

	-- Stage D signals
	signal s_reg_write_w   : std_logic;
	signal s_rd_w		   : std_logic_vector(4 downto 0);
	signal s_result_w	   : std_logic_vector(31 downto 0);
    signal s_rd1, s_rd2	   : std_logic_vector(31 downto 0);
	signal s_imm_ext_d	   : std_logic_vector(31 downto 0);
	signal s_reg_write_d   : std_logic;
	signal s_result_src_d  : std_logic_vector(1 downto 0);
	signal s_mem_write_d   : std_logic;
	signal s_jump_d		   : std_logic;
	signal s_branch_d	   : std_logic;
	signal s_alu_control_d : std_logic_vector(2 downto 0);
	signal s_alu_src_d	   : std_logic;

	-- ID/EX regs
	signal s_flush_e	    : std_logic := '0';
	signal s_reset_d_regs   : std_logic;
	signal s_reg_write_e    : std_logic;
	signal s_result_src_e   : std_logic_vector(1 downto 0);
	signal s_mem_write_e    : std_logic;
	signal s_jump_e		    : std_logic := '0';
	signal s_branch_e	    : std_logic := '0';
	signal s_alu_control_e  : std_logic_vector(2 downto 0);
	signal s_alu_src_e	    : std_logic := '0';
	signal s_rd1_e		    : std_logic_vector(31 downto 0);
	signal s_rd2_e		    : std_logic_vector(31 downto 0);
	signal s_pc_e		    : std_logic_vector(31 downto 0);
	signal s_rs1_e          : std_logic_vector(4 downto 0);
	signal s_rs2_e          : std_logic_vector(4 downto 0);
	signal s_rd_e           : std_logic_vector(4 downto 0);
	signal s_imm_ext_e      : std_logic_vector(31 downto 0);
	signal s_pc_plus_4_e    : std_logic_vector(31 downto 0);

	-- Stage E
	signal s_alu_result_e   : std_logic_vector(31 downto 0);
	signal s_alu_result_m   : std_logic_vector(31 downto 0);
	signal s_forwarding_a_e : std_logic_vector(1 downto 0);
	signal s_forwarding_b_e : std_logic_vector(1 downto 0);
	signal s_write_data_e   : std_logic_vector(31 downto 0);
	signal s_zero_e 	    : std_logic;

	-- EX/MEM regs
	signal s_reg_write_m    : std_logic;
	signal s_result_src_m   : std_logic_vector(1 downto 0);
	signal s_mem_write_m    : std_logic;
	signal s_rd_m   		: std_logic_vector(4 downto 0);
	signal s_pc_plus_4_m    : std_logic_vector(31 downto 0);
	signal s_write_data_m	: std_logic_vector(31 downto 0);

	-- MEM/WB regs
	signal s_result_src_w   : std_logic_vector(1 downto 0);
	signal s_alu_result_w   : std_logic_vector(31 downto 0);
	signal s_read_data_w    : std_logic_vector(31 downto 0);
	signal s_pc_plus_4_w    : std_logic_vector(31 downto 0);

	-- Stage W

begin

	hazard_detection_and_forwarding: hazard_unit
		port map(
			reg_source_id1 => s_instruction_d(19 downto 15),
			reg_source_id2 => s_instruction_d(24 downto 20),
			reg_destin_ex  => s_rd_e,
			result_src_ex  => s_result_src_e(0),
			pc_src_ex      => s_pc_src_e,
			reg_source_ex1 => s_rs1_e,
			reg_source_ex2 => s_rs2_e,
			reg_destin_mm  => s_rd_m,
			reg_destin_wb  => s_rd_w,
			reg_write_mm   => s_reg_write_m,
			reg_write_wb   => s_reg_write_w,
			stall_if       => s_stall_f,
			stall_id       => s_stall_d,
			flush_id       => s_flush_d,
			flush_ex       => s_flush_e,
			alu_op1        => s_forwarding_a_e,
			alu_op2        => s_forwarding_b_e
		);


	s_pc_src_e <= s_jump_e or (s_zero_e and s_branch_e);
	pc <= s_pc_f; -- Output External Interface
	fetch:  stage_f
		port map(
			clock => clock,
			reset => reset,
			pc_src_e => s_pc_src_e,
			stall_f => s_stall_f,
			target_addr => s_pc_target_e,
			pc_out => s_pc_f,
			pc_plus_4 => s_pc_plus_4
		);


	s_reset_f_regs <= s_flush_d or reset;
	s_enable_f_regs <= not(s_stall_d);

	pipe_f: pipe_regF
		port map(
			clk    => clock,
			reset  => s_reset_f_regs,
			enable => s_enable_f_regs,
			PCF_in => s_pc_f,
			PCPlus4F_in => s_pc_plus_4,
			InstrF_in => instruction,
			PCD_out => s_pc_d,
			PCPlus4D_out => s_pc_plus_4_d,
			InstrD_out => s_instruction_d
		);

	decode: stage_d
		port map(
			clock           => clock,
			reset           => reset,
			instruction 	=> s_instruction_d,
			reg_write_w 	=> s_reg_write_w,
			addr_reg_write  => s_rd_w,
			data_reg_in 	=> s_result_w,
			data_reg_src1 	=> s_rd1,
			data_reg_src2 	=> s_rd2,
			imm_ext_d_out   => s_imm_ext_d,
			reg_write_d 	=> s_reg_write_d,
			result_src_d 	=> s_result_src_d,
			mem_write_d 	=> s_mem_write_d,
			jump_d 			=> s_jump_d,
			branch_d 		=> s_branch_d,
			alu_control_d 	=> s_alu_control_d,
			alu_src_d 		=> s_alu_src_d
		);

	s_reset_d_regs <= s_flush_e or reset;

	pipe_d: pipe_regD
		port map(
			clk     		=> clock,
			reset   		=> s_reset_d_regs,
			enable  		=> '1',
			RegWriteD_in 	=> s_reg_write_d,
			ResultSrcD_in 	=> s_result_src_d,
			MemWriteD_in 	=> s_mem_write_d,
			JumpD_in 		=> s_jump_d,
			BranchD_in 		=> s_branch_d,
			ALUControlD_in 	=> s_alu_control_d,
			ALUSrcD_in 		=> s_alu_src_d,
			RD1D_in 		=> s_rd1,
			RD2D_in 		=> s_rd2,
			PCD_in 			=> s_pc_d,
			Rs1D_in 		=> s_instruction_d(19 downto 15),
			Rs2D_in 		=> s_instruction_d(24 downto 20),
			RdD_in 			=> s_instruction_d (11 downto 7),
			ImmExtD_in 		=> s_imm_ext_d,
			PCPlus4D_in 	=> s_pc_plus_4_d,
			RegWriteE_out 	=> s_reg_write_e,
			ResultSrcE_out 	=> s_result_src_e,
			MemWriteE_out 	=> s_mem_write_e,
			JumpE_out 		=> s_jump_e,
			BranchE_out 	=> s_branch_e,
			ALUControlE_out => s_alu_control_e,
			ALUSrcE_out 	=> s_alu_src_e,
			RD1E_out 		=> s_rd1_e,
			RD2E_out 		=> s_rd2_e,
			PCE_out 		=> s_pc_e,
			Rs1E_out 		=> s_rs1_e,
			Rs2E_out 		=> s_rs2_e,
			RdE_out 		=> s_rd_e,
			ImmExtE_out 	=> s_imm_ext_e,
			PCPlus4E_out 	=> s_pc_plus_4_e
		);

	execute: stage_e
	port map(
        clock 				=> clock,
        reset 		  		=> reset,
        data_reg_s1_e		=> s_rd1_e,
        data_reg_s2_e 		=> s_rd2_e,
        pc_e 				=> s_pc_e,
        imm_ext_e 			=> s_imm_ext_e,
        alu_control_e 		=> s_alu_control_e,
        alu_src_e 			=> s_alu_src_e,
        alu_result_m 		=> s_alu_result_m,
        result_w 			=> s_result_w,
        forwarding_a_e 		=> s_forwarding_a_e,
        forwarding_b_e 		=> s_forwarding_b_e,
        alu_result_e 		=> s_alu_result_e,
        write_data_e 		=> s_write_data_e,
        pc_target_e 		=> s_pc_target_e,
        zero_e 				=> s_zero_e
    );

	ReadEnable <= s_result_src_m(0);
	pipe_e: pipe_regE
		port map(
			clk             => clock,
			reset 			=> reset,
			enable			=> '1',
			RegWriteE_in	=> s_reg_write_e,
			ResultSrcE_in	=> s_result_src_e,
			MemWriteE_in	=> s_mem_write_e,
			ALUResultE_in	=> s_alu_result_e,
			WriteDataE_in	=> s_write_data_e,
			RdE_in			=> s_rd_e,
			PCPlus4E_in		=> s_pc_plus_4_e,
			RegWriteM_out	=> s_reg_write_m,
			ResultSrcM_out	=> s_result_src_m,
			MemWriteM_out	=> s_mem_write_m,
			ALUResultM_out	=> s_alu_result_m,
			WriteDataM_out	=> s_write_data_m,
			RdM_out			=> s_rd_m,
			PCPlus4M_out	=> s_pc_plus_4_m
		);

	-- Instruction Memory Interface:
	MemWrite <= s_mem_write_m;
	ALUResult <= s_alu_result_m;
	WriteData <= s_write_data_m;

	pipe_m: pipe_regM
		port map(
			clk              => clock,
			reset            => reset,
			enable           => '1',
			RegWriteM_in     => s_reg_write_m,
			ResultSrcM_in    => s_result_src_m,
			ALUResultM_in    => s_alu_result_m,
			ReadDataM_in     => ReadData,
			RdM_in           => s_rd_m,
			PCPlus4M_in      => s_pc_plus_4_m,
			RegWriteW_out    => s_reg_write_w,
			ResultSrcW_out   => s_result_src_w,
			ALUResultW_out   => s_alu_result_w,
			ReadDataW_out    => s_read_data_w,
			RdW_out          => s_rd_w,
			PCPlus4W_out     => s_pc_plus_4_w
		);

	write_back: stage_w
	port map(
			clock 				=> clock,
			reset 				=> reset,
			read_data_w  		=> s_read_data_w,
			pc_plus_4_w  		=> s_pc_plus_4_w,
			alu_result_m_out 	=> s_alu_result_w,
			result_src_w  		=> s_result_src_w,
			result_w  			=> s_result_w
		);

end;
