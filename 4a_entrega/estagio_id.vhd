----------------------------------------------------------------------------------------------
----------MODULO ESTAGIO DE decodificação E REGISTRADORES-------------------------------------
----------------------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

library work;
use work.tipos.all;

-- O estágio de decodificação e leitura de registradores (id) deve realizar a decodificação 
-- da instrução lida no estágio de
-- busca (if) e produzir os sinais de controle necessários para este estágio, assim como para todos os 
-- demais estágios a seguir.
-- Além disso ele deve realizar a descisao dos desvios condicionais assim como calcular o endereço de 
-- destino para executar essas instruções.
-- Lembrar que no Pipeline com detecção de Hazards e antecipação ("Forwarding"), existirao sinais que
-- influenciarao as decisoes tomadas neste estágio.
-- Neste estágio deve ser feita também a geração dos valores imediatos para todas as instruções. 
-- Atenção especial deve ser dada a esses imediatos pois o RISK-V optou por embaralhar os 
-- imediatos para manter todos os endereços de registradores nas instruções nas mesmas posições 
-- na instrução. 
-- As informações passadas deste estágio para os seguintes devem ser feitas por meio de um 
-- registrador (BID). Para
-- identificar claramente cada campo desse registrador pode-se utilizar o mecanismo do VHDL de definição 
-- de apelidos ("alias").
-- Foi adicionado um sinal para fins de ilustração chamado COP_id que identifica a instrução sendo 
-- processada pelo estágio.
-- Neste estágio deve ser implementado também o módulo de detecção de conflitos - Hazards.
-- Devem existir diversos sinais vindos do outros módulos que sao necessários para a realização das 
-- funções alocadas a este estágio de decodificação - id.
-- A definição dos sinais vindos de outros módulos encontra-se nos comentários da declaração de 
-- entidade do estágio id.

entity estagio_id is
    port(
		-- Entradas
		clock				: in 	std_logic; 						-- Base de tempo- bancada de teste
		BID					: in 	std_logic_vector(063 downto 0);	-- informações vindas estágio Busca
		MemRead_ex			: in	std_logic;						-- Leitura de memória no estagio ex
		rd_ex				: in	std_logic_vector(004 downto 0);	-- Destino nos regs. no estágio ex
		ula_ex				: in 	std_logic_vector(031 downto 0);	-- Saída da ULA no estágio Ex
		MemRead_mem			: in	std_logic;						-- Leitura na memória no estágio mem
		rd_mem				: in	std_logic_vector(004 downto 0);	-- Escrita nos regs. no estágio mem
		ula_mem				: in 	std_logic_vector(031 downto 0);	-- Saída da ULA no estágio Mem 
		NPC_mem				: in	std_logic_vector(031 downto 0); -- Valor do NPC no estagio mem
        RegWrite_wb			: in 	std_logic; 						-- Escrita no RegFile vindo de wb
        writedata_wb		: in 	std_logic_vector(031 downto 0);	-- Valor escrito no RegFile - wb
        rd_wb				: in 	std_logic_vector(004 downto 0);	-- endereço do registrador escrito
        ex_fw_A_Branch		: in 	std_logic_vector(001 downto 0);	-- Seleção de Branch forwardA
        ex_fw_B_Branch		: in 	std_logic_vector(001 downto 0);	-- Seleção de Branch forwardB 
		
		-- Saídas
		id_Jump_PC			: out	std_logic_vector(031 downto 0) := x"00000000";-- Destino JUmp/Desvio
		id_PC_src			: out	std_logic := '0';				-- Seleciona a entrado do PC
		id_hd_hazard		: out	std_logic := '0';				-- Preserva o if_id e nao inc. PC
		id_Branch_nop		: out	std_logic := '0';				-- Sinal de desvio ou salto. 
																	-- limpa o if_id.ri
		rs1_id_ex			: out	std_logic_vector(004 downto 0);	-- endereço rs1 no estágio id
		rs2_id_ex			: out	std_logic_vector(004 downto 0);	-- endereço rs2 no estágio id
		BEX					: out 	std_logic_vector(151 downto 0) := (others => '0');-- Saída do ID > EX
		COP_id				: out	instruction_type  := NOP;		-- Instrucao no estagio id
		COP_ex				: out 	instruction_type := NOP			-- instrução no estágio id passada> EX
    );
end entity;

architecture behav of estagio_id is
    signal s_instruction_rs1: std_logic_vector(4 downto 0);
    signal s_instruction_rs2: std_logic_vector(4 downto 0);

    begin
        s_instruction_rs1 <= BID(19 downto 15);
        s_instruction_rs2 <= BID(24 downto 20);

        hazard_unit: process(MemRead_ex, s_instruction_rs1, s_instruction_rs2, rd_ex)
        begin
            if MemRead_ex = '1' and ((s_instruction_rs1 = rd_ex) or (s_instruction_rs2 = rd_ex)) then
                id_hd_hazard <= '1';
            else
                id_hd_hazard <= '0';
            end if;
        end process hazard_unit;

        rs1_id_ex <= s_instruction_rs1;
        rs2_id_ex <= s_instruction_rs2;

end architecture;