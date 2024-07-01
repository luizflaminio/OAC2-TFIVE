----------------------------------------------------------------------------------------------
----------MODULO ESTAGIO DE decodificação E REGISTRADORES-------------------------------------
----------------------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

library work;
use work.tipos.all;
use work.opcode_converter.all;

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

    component regfile is
        port(
            -- Entradas
            clock			: 	in 		std_logic;						-- Base de tempo - Bancada de teste
            RegWrite		: 	in 		std_logic; 						-- Sinal de escrita no RegFile
            read_reg_rs1	: 	in 		std_logic_vector(04 downto 0);	-- Endere�o do registrador na sa�da RA
            read_reg_rs2	: 	in 		std_logic_vector(04 downto 0);	-- Endere�o do registrador na sa�da RB
            write_reg_rd	: 	in 		std_logic_vector(04 downto 0);	-- Endere�o do registrador a ser escrito
            data_in			: 	in 		std_logic_vector(31 downto 0);	-- Valor a ser escrito no registrador
            
            -- Sa�das
            data_out_a		: 	out 	std_logic_vector(31 downto 0);	-- Valor lido pelo endere�o rs1
            data_out_b		: 	out 	std_logic_vector(31 downto 0) 	-- Valor lido pelo enderc�o rs2
        );
    end component;

    -- Sinais para decodificação da instrução
    signal PC_id          : std_logic_vector(31 downto 0);
    signal PC_plus_4      : std_logic_vector(31 downto 0);
    signal opcode         : std_logic_vector(6 downto 0);
    signal rs1, rs2, rd   : std_logic_vector(4 downto 0);
    signal funct3         : std_logic_vector(2 downto 0);
    signal funct7         : std_logic_vector(6 downto 0);
    signal imm            : std_logic_vector(19 downto 0);
    signal imm_type       : std_logic_vector(1 downto 0);
    signal imm_ext        : std_logic_vector(31 downto 0);
    signal gpr_rs1        : std_logic_vector(31 downto 0);
    signal gpr_rs2        : std_logic_vector(31 downto 0);
    signal branch_Data_A  : std_logic_vector(31 downto 0);
    signal branch_Data_B  : std_logic_vector(31 downto 0);
    signal aluop_id       : std_logic_vector(2 downto 0);
    signal alusrc_id      : std_logic;
    signal memread_id     : std_logic;
    signal memwrite_id    : std_logic;
    signal regwrite_id    : std_logic;
    signal memtoreg_id    : std_logic_vector(1 downto 0);
    signal exception      : std_logic := '0';
    signal SEPC           : std_logic_vector(31 downto 0) := x"00000000";
    signal SCAUSE         : std_logic_vector(1 downto 0) := "00";
    signal s_COP_id	      : instruction_type  := NOP;

    begin

        set_COP_id: process(s_COP_id)
        begin
            COP_id <= s_COP_id;
        end process;

        set_opcode: process(BID)
        begin
            opcode <= BID(6 downto 0);
            PC_id <= BID(63 downto 32);
            s_COP_id <= decode(BID(31 downto 0));
            funct3 <= BID(14 downto 12);
            funct7 <= BID(31 downto 25);
        end process;

        decode: process(opcode, funct3, funct7, BID)
        begin
            if opcode = "0110011" then -- R-type
                memtoreg_id <= "01"; -- saida ULA
                regwrite_id <= '1';
                memwrite_id <= '0';
                memread_id <= '0';
                alusrc_id <= '0';
                rd     <= BID(11 downto 7);
                rs2    <= BID(24 downto 20);
                rs1    <= BID(19 downto 15);
                case funct3 is 
                    when "000" => -- ADD
                        aluop_id <= "000";
                        id_PC_src <= '0';
                        id_Branch_nop <= '0';
                        exception <= '0';
                    when "010" => -- SLT
                        aluop_id <= "010";
                        id_PC_src <= '0';
                        id_Branch_nop <= '0';
                        exception <= '0';
                    when others =>
                        id_PC_src <= '1';
                        id_Branch_nop <= '1';
                        exception <= '1';
                end case;
            elsif opcode = "0010011" then -- I-type
                memtoreg_id <= "01"; -- saida ULA
                regwrite_id <= '1';
                memwrite_id <= '0';
                memread_id <= '0';
                alusrc_id <= '1';
                rd  <= BID(11 downto 7);
                rs2 <= "00000";
                rs1 <= BID(19 downto 15);
                imm <= "00000000" & BID(31 downto 20);
                imm_type <= "01";
                case funct3 is 
                    when "000" => -- ADDI
                        aluop_id <= "000";
                        id_PC_src <= '0';
                        id_Branch_nop <= '0';
                        exception <= '0';
                    when "010" => -- SLTI
                        aluop_id <= "010";
                        id_PC_src <= '0';
                        id_Branch_nop <= '0';
                        exception <= '0';
                    when "001" => -- SLLI
                        aluop_id <= "011";
                        id_PC_src <= '0';
                        id_Branch_nop <= '0';
                        exception <= '0';
                    when "101" => 
                        if funct7 = "0000000" then -- SRLI
                            aluop_id <= "100";
                            id_PC_src <= '0';
                            id_Branch_nop <= '0';
                            exception <= '0';
                        elsif funct7 = "0100000" then -- SRAI
                            aluop_id <= "101";
                            id_PC_src <= '0';
                            id_Branch_nop <= '0';
                            exception <= '0';
                        else
                            id_PC_src <= '1';
                            id_Branch_nop <= '1';
                            exception <= '1';
                        end if;
                    when others =>
                        id_PC_src <= '1';
                        id_Branch_nop <= '1';
                        exception <= '1';
                end case;
            elsif opcode = "0000011" then -- LW
                memtoreg_id <= "10"; -- saida memória
                regwrite_id <= '1';
                memwrite_id <= '0';
                memread_id <= '1';
                alusrc_id <= '1';
                aluop_id <= "000";
                rd  <= BID(11 downto 7);
                rs2 <= "00000";
                rs1 <= BID(19 downto 15);
                imm <= "00000000" & BID(31 downto 20);
                imm_type <= "01";
                id_PC_src <= '0';
                id_Branch_nop <= '0';
                exception <= '0';
            elsif opcode = "0100011" then  -- SW
                memtoreg_id <= "01"; -- saida ULA
                regwrite_id <= '0'; 
                memwrite_id <= '1';
                memread_id <= '0';
                alusrc_id <= '1';
                aluop_id <= "000";
                rd  <= BID(24 downto 20);
                rs2 <= "00000";
                rs1 <= BID(19 downto 15);
                imm <= "00000000" & BID(31 downto 25) & BID(11 downto 7);
                imm_type <= "01";
                id_PC_src <= '0';
                id_Branch_nop <= '0';
                exception <= '0';
            elsif opcode = "1100011" then -- BRANCH
                memtoreg_id <= "01"; -- saida ULA
                regwrite_id <= '0'; 
                memwrite_id <= '1';
                memread_id <= '0';
                alusrc_id <= '1';
                aluop_id <= "000";
                rd <= "00000";
                rs2 <= BID(24 downto 20);
                rs1 <= BID(19 downto 15);
                imm <= "00000000" & BID(31) & BID(7) & BID(30 downto 25) & BID(11 downto 8);
                imm_type <= "00";
                case funct3 is
                    when "000" => -- BEQ
                        if (branch_Data_A = branch_Data_B) then
                            id_PC_src <= '1';
                            id_Branch_nop <= '1';
                            exception <= '0';
                        end if;
                    when "001" => -- BNE
                        if (branch_Data_A /= branch_Data_B) then
                            id_PC_src <= '1';
                            id_Branch_nop <= '1';
                            exception <= '0';
                        end if;
                    when "100" => -- BLT
                        if (signed(branch_Data_A) < signed(branch_Data_B)) then
                            id_PC_src <= '1';
                            id_Branch_nop <= '1';
                            exception <= '0';
                        end if;
                    when others =>
                        id_PC_src <= '1';
                        id_Branch_nop <= '1';
                        exception <= '1';
                end case;
            elsif opcode = "1101111" then -- JAL
                memtoreg_id <= "00"; -- saida ULA
                regwrite_id <= '1'; 
                memwrite_id <= '0';
                memread_id <= '0';
                alusrc_id <= '0';
                aluop_id <= "000";
                rd <= BID(11 downto 7);
                rs2 <= "00000";
                rs1 <= "00000";
                imm <= BID(31) & BID(19 downto 12) & BID(22) & BID(30 downto 21);
                imm_type <= "10";
                id_PC_src <= '1';
                id_Branch_nop <= '1';
                exception <= '0';
            elsif opcode = "1100111" then -- JALR
                memtoreg_id <= "01"; -- saida ULA
                regwrite_id <= '1'; 
                memwrite_id <= '0';
                memread_id <= '0';
                alusrc_id <= '0';
                aluop_id <= "000";
                rd <= BID(11 downto 7);
                rs2 <= "00000";
                rs1 <= BID(19 downto 15);
                imm <= "00000000" & BID(31 downto 20);
                imm_type <= "00";
                id_PC_src <= '1';
                id_Branch_nop <= '1';
                exception <= '0';
            elsif opcode = "0000000" then -- NOP
                memtoreg_id <= "01"; -- saida ULA
                regwrite_id <= '1';
                memwrite_id <= '0';
                memread_id <= '0';
                alusrc_id <= '1';
                aluop_id <= "011";
                rd  <= BID(11 downto 7);
                rs2 <= "00000";
                rs1 <= BID(19 downto 15);
                id_PC_src <= '0';
                id_Branch_nop <= '0';
                exception <= '0';
            else
                id_PC_src <= '1';
                id_Branch_nop <= '1';
                exception <= '1';
            end if;
        end process;

        extend_imm: process(imm, imm_type)
        begin
            case imm_type is
                when "00" =>
                    -- Extensão para Branch (12 bits)
                    if imm(11) = '0' then
                        imm_ext <= "0000000000000000000" & imm(11 downto 0) & '0'; -- Zero extension + bit 0
                    else
                        imm_ext <= "1111111111111111111" & imm(11 downto 0) & '0'; -- Sign extension + bit 0
                    end if;
                when "01" =>
                    -- Extensão para outros (12 bits)
                    if imm(11) = '0' then
                        imm_ext <= "00000000000000000000" & imm(11 downto 0); -- Zero extension
                    else
                        imm_ext <= "11111111111111111111" & imm(11 downto 0); -- Sign extension
                    end if;
                when "10" =>
                    -- Extensão para Jump (20 bits)
                    if imm(19) = '0' then
                        imm_ext <= "00000000000" & imm(19 downto 0) & '0'; -- Zero extension + bit 0
                    else
                        imm_ext <= "11111111111" & imm(19 downto 0) & '0'; -- Sign extension + bit 0
                    end if;
                when others =>
                    imm_ext <= (others => '0'); -- Caso padrão para evitar latches
            end case;
        end process;

        calc_branch_addrs: process(imm_ext, exception, opcode)
        begin
            if exception = '1' then
                id_Jump_PC <= x"00000400";
            elsif opcode = "1100111" then -- JALR
                id_Jump_PC <= std_logic_vector(signed(gpr_rs1) + signed(imm_ext));
            elsif opcode = "1100011" or opcode = "1101111" then -- BRANCH e JAL
                id_Jump_PC <= std_logic_vector(signed(PC_id) + signed(imm_ext));
            else 
                id_Jump_PC <= x"00000000";
            end if;
        end process;

        PC_plus_4 <= std_logic_vector(to_unsigned(to_integer(unsigned(PC_id)) + 4, PC_plus_4'length));

        sepc_process: process(clock)
        begin
            if(rising_edge(clock)) then
                if(exception = '1') then
                    SEPC <= BID(63 downto 32);
                end if;
            end if;
        end process;

        scause_process: process(clock)
        begin
            if(rising_edge(clock)) then
                if(exception = '1') then
                    SCAUSE <= "10";
                end if;
            end if;
        end process;

        forwarding_process: process(ex_fw_A_Branch, ex_fw_B_Branch)
        begin
            if(ex_fw_A_Branch = "00") then
                branch_Data_A <= gpr_rs1;
            elsif(ex_fw_A_Branch = "01") then 
                branch_Data_A <= ula_ex;
            elsif(ex_fw_A_Branch = "10") then
                branch_Data_A <= writedata_wb;
            else 
                branch_Data_A <= x"00000000";
            end if;

            if(ex_fw_B_Branch = "00") then
                branch_Data_B <= gpr_rs2;
            elsif(ex_fw_B_Branch = "01") then 
                branch_Data_B <= ula_ex;
            elsif(ex_fw_B_Branch = "10") then
                branch_Data_B <= writedata_wb;
            else 
                branch_Data_B <= x"00000000";
            end if;
        end process;

        hazard_process: process(MemRead_ex, rs2, rs1, rd_ex)
        begin
            if (MemRead_ex = '1' and ((rs1 = rd_ex) or (rs2 = rd_ex))) then
                id_hd_hazard <= '1';
            else
                id_hd_hazard <= '0';
            end if;  
        end process;

        set_rs_id_ex: process(rs1, rs2, clock)
        begin 
            rs1_id_ex <= rs1;
            rs2_id_ex <= rs2;
        end process;
        -- Comportamental
        process(clock)
        begin
            if rising_edge(clock) then
                COP_ex <= s_COP_id;
                    
                BEX(151 downto  150) <= memtoreg_id;
                BEX(149) <= regwrite_id;
                BEX(148) <= memwrite_id;
                BEX(147) <= memread_id; 
                BEX(146) <= alusrc_id;
                BEX(145 downto 143) <= aluop_id;
                BEX(142 downto 138) <= rd;
                BEX(137 downto 133) <= rs2;
                BEX(132 downto 128) <= rs1;
                BEX(127 downto 96) <= PC_plus_4;
                BEX(95 downto 64) <= imm_ext;
                BEX(63 downto 32) <= gpr_rs2;
                BEX(31 downto 0) <= gpr_rs1;
            end if;
        end process;

        -- Estrutural: a escrita é controlada pelo estagio wb 
        regfile_inst: regfile
            port map(
                clock       => clock,
                RegWrite    => RegWrite_wb,
                read_reg_rs1=> rs1,
                read_reg_rs2=> rs2,
                write_reg_rd=> rd,
                data_in     => writedata_wb,
                data_out_a  => gpr_rs1,
                data_out_b  => gpr_rs2
            );

end architecture;