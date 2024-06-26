---------------------------------------------------------------------------------------------------------
---------------MOD�LO DE BUSCA - IF -------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.tipos.all;
use work.opcode_converter.all;

-- Especificaçao do estágio de BUSCA - if
-- estágio de Busca de Instruções - if: neste estágio se encontra o PC(PC_if) (Contador de Programa) 
-- o Registrador de Instruções ri_if,o registrador  
-- NPC (NPC_if = PC incrementado de 4), a memória Cache de instruções - iMEM e um conjunto de informações 
-- passadas ao estágio de decodificação-id.
-- Essas informações sao passadas por um sinal chamado BID (Buffer para o estágio id). Este buffer é de 
-- saído do estágio if 
-- e de entrada no estágio id. Este estágio recebe sinais vindos de outros estágios, a saber:
--		clock; Sinal vindo da Bancada de teste que implementa o relógio do Pipeline;
-- 		id_hd_hazard: Sinal de controle vindo do estágio id, no módulo hd, que carrega 0's na parte do ri  
-- 			do registrador de saída do estágio de Busca (BID) quando da ocorrência de um conflito;
-- 		id_hd_Branch_nop:Sinal vindo do estágio id, do módulo hd, que indica inserção de NoP devido  
--          a desvio ou pulo;
-- 		id_PC_Src: Sinal vindo do estágio id que define a seleçao do multiplexador da entrada 
--		do registrador PC;
-- 		id_Jump_PC: Sinal vindo do estágio id com o endereço destino ("target") dos Pulos ou desvios  
--			a serem realizados.
--		keep_simulating: sinal que indica continuação (true) ou parada (false) da simulação.
-- O BID possui 64 bits alocados da seguinte forma: o ri_if nas posições de 0 a 31 e o PC_if de 32 a 63.

entity estagio_if is
    generic(
        imem_init_file: string := "imem.txt" -- Nome do arquivo com o conteúdo da memoria de programa
    );
    port(
        -- Entradas
        clock           : in std_logic; -- Base de tempo vinda da bancada de teste
        id_hd_hazard    : in std_logic; -- Sinal de controle que carrega 0's na parte do RI do registrador de saída BID
        id_Branch_nop   : in std_logic; -- Sinal que determina inserção de NOP- desvio ou pulo
        id_PC_Src       : in std_logic; -- Seleção do mux da entrada do PC
        id_Jump_PC      : in std_logic_vector(31 downto 0) := x"00000000"; -- Endereço do Jump ou desvio realizado
        keep_simulating : in boolean; -- Sinal que indica a continuação da simulação
        -- Saída
        BID             : out std_logic_vector(63 downto 0) := x"0000000000000000" -- Reg. de saída if para id
    );
end entity;

architecture behav of estagio_if is
    
    component ram is
        generic(
            address_bits    : integer := 32; -- Número de bits de endereço da memória
            size            : integer := 4096; -- Tamanho da memória em bytes
            ram_init_file   : string := "imem.txt" -- Arquivo que contém o conteúdo da memória
        );
        port (
            -- Entradas
            clock   : in std_logic; -- Base de tempo, memória síncrona para escrita
            write   : in std_logic; -- Sinal de escrita na memória
            address : in std_logic_vector(address_bits-1 downto 0); -- Entrada de endereço da memória
            data_in : in std_logic_vector(address_bits-1 downto 0); -- Entrada de dados na memória
            
            -- Saída
            data_out: out std_logic_vector(address_bits-1 downto 0) -- Saída de dados da memória
        );
    end component;
    
    signal s_reset: std_logic;
    signal s_halt: std_logic := '0';
    signal s_instruction : std_logic_vector(31 downto 0);
    signal ri_if : std_logic_vector(31 downto 0);
    signal s_PC  : std_logic_vector(31 downto 0) := x"00000000";
    signal s_pc_plus_4  : std_logic_vector(31 downto 0) := x"00000000";
    signal s_pc_mux  : std_logic_vector(31 downto 0);
    signal COP_IF : instruction_type := NOP;

begin
    s_reset <= '0' when keep_simulating else '1';
    -- Como foi inserido o endereço de interrupção/exceção?
    -- O endereço de interrupção é uma das entradas do mux que determina qual o PC a ser usado, é selecionado a partir do sinal id_Branch_nop
    -- Já o endereço de exceção foi implementado como sujerido no enunciado, o endereço 0x00000400 e é selecionado pelo sinal id_PC_src

    s_pc_plus_4 <= std_logic_vector(to_unsigned(to_integer(unsigned(s_PC)) + 4, s_pc_plus_4'length));

    pc_source_process: process(id_PC_src, s_pc_plus_4, id_Jump_PC)
        begin
            if(id_PC_src = '1') then
                s_pc_mux <= id_Jump_PC;
            else
                s_pc_mux <= s_pc_plus_4;
            end if;
    end process;

    -- Como se implementou a preservação do valor do PC?
    -- O valor de PC só atualiza se id_hd_hazard = '1'

    pc_process: process(clock)
    begin
        if(rising_edge(clock)) then
            if(id_hd_hazard = '0' and s_halt = '0') then
                S_PC <= s_pc_mux;
            else
                S_PC <= S_PC;
            end if;
        end if;
    end process;

    -- Como se implementou a inserção de NOPs?
    -- Se o sinal de hazard estiver ativo, passa-se adiante a inserção de bolhas

    branch_process: process(s_instruction, id_Branch_nop)
        begin
            if(id_Branch_nop = '1') then
                ri_if <= x"00000000";
            else
                ri_if <= s_instruction;
            end if;
    end process;
    
    COP_IF <= decode(ri_if);

    bid_process: process(clock)
    begin
        if(id_hd_hazard = '0' and rising_edge(clock)) then
            BID <= s_PC & ri_if;
        end if;
    end process;

    halt: process
    begin
        wait until (ri_if = x"0000006F" and falling_edge(clock));
        s_halt <= '1';
    end process;

    imem: ram
        generic map(
            address_bits    => 32,
            size            => 4096,
            ram_init_file   => imem_init_file
        )
        port map(
            clock       => clock,
            write       => '0',
            address     => s_PC,
            data_in     => (others => '0'),
            data_out    => s_instruction
        );

end behav;
