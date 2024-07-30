----------------------------------------------------------------------------------------------------
-------------MODULO ESTAGIO DE EXECUÇÃO-------------------------------------------------------------
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

library work;
use work.tipos.all;

-- Especificação do estagio Executa - ex: declaração de entidade
-- Neste estágio sao executadas as instruções do tipo RR e calculado os endereços 
-- das instruções de load e store.
-- O módulo que implementa a antecipação de valores (Forwarding) é feita neste estágio 
-- num módulo separado dentro do estágio ex.
-- A unidade lógica e aritmética - ULA - fica neste estágio.
-- Os multiplexadores de estrada da ULA que selecionam os valores corretos dependendo 
-- da antecipação ficam neste estágio.
-- A definição do sinais de entrada e saída do estágio EX encontram-se na declaração 
-- da entidade estágio_ex e sao passados pelo registrador BEX

entity estagio_ex_grupo10 is
    port(
		-- Entradas
		clock				: in 	std_logic;					  		-- Relógio do Sistema
      	BEX					: in 	std_logic_vector (151 downto 0);  	-- Dados vindos do id
		COP_ex				: in 	instruction_type;				  	-- Mnemônico no estágio ex
		ula_mem				: in 	std_logic_vector (031 downto 0);	-- ULA no estágio de memória
		rs1_id_ex			: in	std_logic_vector (004 downto 0);    -- rs1 no estágio id para o ex
		rs2_id_ex			: in	std_logic_vector (004 downto 0);    -- rs2 no estágio id para o ex
		MemRead_mem			: in 	std_logic;					  		-- Leitura na memória no  mem
		RegWrite_mem		: in 	std_logic;					  		-- Escrita nos regs. no  mem
		rd_mem				: in 	std_logic_vector (004 downto 0);	-- Destino nos regs. mem
		RegWrite_wb			: in	Std_logic;							-- Escrita nos regs no estagio wb
		rd_wb				: in	std_logic_vector (004 downto 0);	-- Destino no rges no estágio wb
		writedata_wb		: in 	std_logic_vector (031 downto 0);	-- Dado a ser escrito no regs.
		Memval_mem			: in	std_logic_vector (031 downto 0);	-- Saída da memória no mem
		
		-- Saídas
		MemRead_ex			: out	std_logic;							-- Leitura da memória no ex 
		rd_ex				: out	std_logic_vector (004 downto 0);	-- Destino dos regs no ex
		ULA_ex				: out	std_logic_vector (031 downto 0);	-- ULA no estágio ex
		ex_fw_A_Branch		: out 	std_logic_vector (001 downto 0);	-- Dado comparado em A no id 
																		-- em desvios com forward
        ex_fw_B_Branch		: out 	std_logic_vector (001 downto 0);	-- Dado comparado em B no id 
																		-- em desvios com forward
        BMEM				: out 	std_logic_vector (115 downto 0) := (others => '0'); -- dados para mem
		COP_mem				: out 	instruction_type := NOP			  	-- Mnemônico no estágio mem
		
		);
end entity;

architecture behavioral of estagio_ex_grupo10 is
	component alu is
		port(
			-- Entradas
			in_a		: in 	std_logic_vector(31 downto 0);
			in_b		: in 	std_logic_vector(31 downto 0);
			ALUOp		: in 	std_logic_vector(02 downto 0);
			-- Saídas
			ULA			: out 	std_logic_vector(31 downto 0);
			zero		: out 	std_logic
		);
	end component;
	
	signal s_ula_src_a, s_ula_src_b, s_alu_result, s_rs1_data, s_rs2_data, s_alu_mux_b, s_imm_ext: std_logic_vector(31 downto 0);
	signal s_aluop: std_logic_vector(2 downto 0);
	signal s_forwardA, s_forwardB: std_logic_vector(1 downto 0);
	signal s_alusrc: std_logic;
	signal s_rd_ex: std_logic_vector (4 downto 0);
	signal s_MemToReg_ex: std_logic_vector(1 downto 0);
	signal s_RegWrite_ex: std_logic;
	signal s_MemWrite_ex: std_logic;
	signal s_NPC_ex, s_dado_arma_ex : std_logic_vector(31 downto 0);
	signal s_rs1, s_rs2: std_logic_vector(4 downto 0);

begin
	s_MemToReg_ex <= BEX(151 downto 150);
	s_RegWrite_ex <= BEX(149);
	s_MemWrite_ex <= BEX(148);
	MemRead_ex <= BEX(147);
	s_NPC_ex <= BEX(127 downto 96);
	s_dado_arma_ex <= BEX(63 downto 32);
	s_rd_ex <= BEX(142 downto 138);
	s_rs2 <= BEX(137 downto 133);
	s_rs1 <= BEX(132 downto 128);
	rd_ex <= BEX(142 downto 138);

	set_COP_mem: process(clock)
	begin
		if rising_edge(clock) then
			COP_mem <= COP_ex;
		end if;
	end process;

	-- forwarding_unit: process
	forwarding_unit: process(rs1_id_ex, rs2_id_ex, RegWrite_mem, rd_mem, rd_wb, s_RegWrite_ex, s_rd_ex)
		begin
			if (RegWrite_mem = '1'and rd_mem /= "0000" and (rd_mem = s_rs1)) then
				s_forwardA <= "01";
			elsif (RegWrite_wb = '1' and rd_wb /= "0000" and (rd_wb = s_rs1)) then
				s_forwardA <= "10";
			else 
				s_forwardA <= "00";
			end if;

			if (RegWrite_mem = '1'and rd_mem /= "0000" and (rd_mem = s_rs2)) then
				s_forwardB <= "01";
			elsif (RegWrite_wb = '1' and rd_wb /= "0000" and (rd_wb = s_rs2)) then
				s_forwardB <= "10";
			else 
				s_forwardB <= "00";
			end if;
		end process;

		-- forwarding branch
		forwarding_branch: process(rs1_id_ex, rs2_id_ex, s_rd_ex, rd_mem, s_RegWrite_ex, RegWrite_mem, s_MemToReg_ex)
		begin
			if(rs1_id_ex = s_rd_ex and s_RegWrite_ex = '1' and s_MemToReg_ex = "00") then
				ex_fw_A_Branch <= "10";
			elsif (rs1_id_ex = rd_mem and RegWrite_mem = '1' and s_MemToReg_ex = "00") then
				ex_fw_A_Branch <= "01";
			elsif (rs1_id_ex = rd_mem and s_MemToReg_ex = "10") then
				ex_fw_A_Branch <= "11";
			else
				ex_fw_A_Branch <= "00";
			end if;

			if(rs2_id_ex = s_rd_ex and s_RegWrite_ex = '1' and s_MemToReg_ex = "00") then
				ex_fw_B_Branch <= "10";
			elsif (rs2_id_ex = rd_mem and RegWrite_mem = '1' and s_MemToReg_ex = "00") then
				ex_fw_B_Branch <= "01";
			elsif (rs2_id_ex = rd_mem and s_MemToReg_ex = "10") then
				ex_fw_B_Branch <= "11";
			else
				ex_fw_B_Branch <= "00";
			end if;
		end process;

	ula_control: process(BEX)
		begin
			s_aluop <= BEX(145 downto 143);
			s_alusrc <= BEX(146);
			s_rs1_data <= BEX(31 downto 0);
			s_rs2_data <= BEX(63 downto 32);
			s_imm_ext <= BEX(95 downto 64);
	end process;
	
	ula_src_a: process(s_forwardA, s_rs1_data, ula_mem, writedata_wb)
		begin
			if(s_forwardA = "01") then -- definir os valores de cada um a ser utilizado
				s_ula_src_a <= ula_mem;
			elsif(s_forwardA = "10") then
				s_ula_src_a <= writedata_wb;
			else
				s_ula_src_a <= s_rs1_data;
			end if;
		end process;

	ula_mux_b: process(s_forwardB, s_rs2_data, ula_mem, writedata_wb)
		begin
			if(s_forwardB = "01") then -- definir os valores de cada um a ser utilizado
				s_alu_mux_b <= ula_mem;
			elsif(s_forwardB = "10") then
				s_alu_mux_b <= writedata_wb;
			else
				s_alu_mux_b <= s_rs2_data;
			end if;
		end process;

	ula_src_b: process(s_alusrc, s_imm_ext, s_alu_mux_b)
		begin
			if(s_alusrc = '1') then -- definir os valores de cada um a ser utilizado
				s_ula_src_b <= s_imm_ext;
			else
				s_ula_src_b <= s_alu_mux_b;
			end if;
		end process;
	-- ULA: instanciada estruturalmente:
	ula: alu
		port map(
			in_a => s_ula_src_a,
			in_b => s_ula_src_b,
			ALUOp => s_aluop,
			ULA => s_alu_result,
			zero => open -- ver se tem alguma utilidade
		);

	ULA_ex <= s_alu_result;

	process(clock)
	begin
		if rising_edge(clock) then
			BMEM(115 downto 114) <= s_MemToReg_ex;
			BMEM(113)            <= s_RegWrite_ex;
			BMEM(112)            <= s_MemWrite_ex;
			BMEM(111)            <= BEX(147); -- MemRead_ex
			BMEM(110 downto 79)  <= s_NPC_ex;
			BMEM(78 downto 47)   <= s_alu_result;
			if (s_forwardB = "10") then
				BMEM(46 downto 15) <= writedata_wb;
			else
				BMEM(46 downto 15) <= s_dado_arma_ex;
			end if;
			BMEM(14 downto 10)   <= s_rs1;
			BMEM(9 downto 5)     <= s_rs2;
			BMEM(4 downto 0)     <= s_rd_ex;
		end if;
	end process;
end behavioral;