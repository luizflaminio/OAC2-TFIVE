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
    signal instruction    : std_logic_vector(31 downto 0); 
    signal PC_id          : std_logic_vector(31 downto 0);
    signal opcode         : std_logic_vector(6 downto 0);
    signal rs1, rs2, rd   : std_logic_vector(4 downto 0);
    signal funct3         : std_logic_vector(2 downto 0);
    signal funct7         : std_logic_vector(6 downto 0);
    signal imm            : std_logic_vector(31 downto 0);
    signal gpr_rs1        : std_logic_vector(31 downto 0);
    signal gpr_rs2        : std_logic_vector(31 downto 0);
    signal branch_Data_A  : std_logic_vector(31 downto 0);
    signal branch_Data_B  : std_logic_vector(31 downto 0);
    signal base           : std_logic_vector(4 downto 0);
    signal offset         : std_logic_vector(11 downto 0);
    signal store_offset   : std_logic_vector(6 downto 0);
    signal store_ofst     : std_logic_vector(4 downto 0);
    signal exception      : std_logic;
    signal SEPC           : std_logic;
    signal SCAUSE         : std_logic;

    begin
        -- Comportamental
        process(clock)
        begin
            if rising_edge(clock) then
                instruction <= BID(31 downto 0);
                PC_id <= BID(63 downto 32);
                opcode <= instruction(6 downto 0);

                -- Tem um monte de sinais aqui que nao estao sendo usados atualmente, mas tlvz em breve?
                case opcode is
                    when "0110011" => -- R-type
                        rd     <= instruction(11 downto 7);
                        funct3 <= instruction(14 downto 12);
                        rs1    <= instruction(19 downto 15);
                        rs2    <= instruction(24 downto 20);
                        funct7 <= instruction(31 downto 25);
                        exception <= '0';
                    when "0010011" => -- I-type
                        rd     <= instruction(11 downto 7);
                        funct3 <= instruction(14 downto 12);
                        rs1    <= instruction(19 downto 15);
                        exception <= '0';
                    when "0000011" => -- LOAD
                        rd     <= instruction(11 downto 7);
                        base   <= instruction(19 downto 15);
                        offset <= instruction(31 downto 20);
                        exception <= '0';
                    when "0100011" => -- STORE
                        store_ofst   <= instruction(11 downto 7);
                        base         <= instruction(19 downto 15);
                        rs2          <= instruction(24 downto 20);
                        store_offset <= instruction(31 downto 25);
                        exception <= '0';
                    when "1100011" => -- BRANCH
                        rs1 <= instruction(19 downto 15);
                        rs2 <= instruction(24 downto 20);
                        exception <= '0';
                    when "1101111" => -- JAL
                        rd <= instruction(11 downto 7);
                        exception <= '0';
                    when "1100111" => -- JALR
                        rd  <= instruction(11 downto 7);
                        rs1 <= instruction(19 downto 15);
                        exception <= '0';
                    when others => 
                        -- Sanar duvida: as pseudo instrucoes (ex: HALT, J, Jr, NOP) possuem opcode proprio?     
                        -- Exceção
                        exception <= '1';
                        id_Jump_PC <= x"00000400";
                        id_PC_src <= '1';
                        id_Branch_nop <= '1';
                end case;
                
                if(exception = '1') then
                    SEPC <= '1';
                    SCAUSE <= '1';
                else
                    SEPC <= '0';
                    SCAUSE <= '0';
                end if;       

                -- Calculo do imediato
                case opcode is
                    when "0010011" => -- I-type
                        imm <= std_logic_vector(resize(unsigned(instruction(31 downto 20)),32));
                    when "1100011" => -- BRANCH
                        imm <= std_logic_vector(resize(unsigned(instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0'), 32));
                    when "1101111" => -- JAL
                        imm <= std_logic_vector(resize(unsigned(instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0'), 32));
                    when "1100111" => -- JALR
                        imm <= std_logic_vector(resize(unsigned(instruction(31 downto 20)),32));
                    when others =>
                        imm <= (others => '0');
                end case;

                 -- forwarding
                if(ex_fw_A_Branch = "00") then
                    branch_Data_A <= gpr_rs1;
                elsif(ex_fw_A_Branch = "01") then 
                    branch_Data_A <= ula_ex;
                elsif(ex_fw_A_Branch = "10") then
                    branch_Data_A <= writedata_wb;
                end if;

                if(ex_fw_B_Branch = "00") then
                    branch_Data_B <= gpr_rs2;
                elsif(ex_fw_B_Branch = "01") then 
                    branch_Data_B <= ula_ex;
                elsif(ex_fw_B_Branch = "10") then
                    branch_Data_B <= writedata_wb;
                end if;
                
                -- Desvios condicionais
                if (opcode = "1100011") then -- BRANCH
                    case funct3 is
                        when "000" => -- BEQ
                            if (branch_Data_A = branch_Data_B) then
                                id_Jump_PC <= std_logic_vector(unsigned(PC_id) + unsigned(signed(imm)));
                                id_PC_src <= '1';
                                id_Branch_nop <= '1';
                            end if;
                        when "001" => -- BNE
                            if (branch_Data_A /= branch_Data_B) then
                                id_Jump_PC <= std_logic_vector(unsigned(PC_id) + unsigned(signed(imm)));
                                id_PC_src <= '1';
                                id_Branch_nop <= '1';
                            end if;
                        when "100" => -- BLT
                            if (signed(branch_Data_A) < signed(branch_Data_B)) then
                                id_Jump_PC <= std_logic_vector(unsigned(PC_id) + unsigned(signed(imm)));
                                id_PC_src <= '1';
                                id_Branch_nop <= '1';
                            end if;
                        when others =>
                                id_PC_src <= '0';
                                id_Branch_nop <= '0';
                    end case;
                end if;

                -- Desvios incondicionais
                if (opcode = "1101111") then -- JAL
                    id_Jump_PC <= std_logic_vector(unsigned(PC_id) + unsigned(signed(imm)));
                    id_PC_src <= '1';
                    id_Branch_nop <= '1';
                elsif (opcode = "1100111") then -- JALR
                    id_Jump_PC <= std_logic_vector(unsigned(gpr_rs1) + unsigned(signed(imm)));
                    id_PC_src <= '1';
                    id_Branch_nop <= '1';
                end if;
                
                -- hazard
                if (MemRead_ex = '1' and ((rs1 = rd_ex) or (rs2 = rd_ex))) then
                    id_hd_hazard <= '1';
                else
                    id_hd_hazard <= '0';
                end if;               
    
            end if;
        end process;

        -- Estrutural
        -- Sanar duvida: ha alguma escrida no regfile em ID?
        -- R: a escrita é controlada pelo estagio wb 
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