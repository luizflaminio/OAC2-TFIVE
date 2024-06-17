---------------------------------------------------------------------------------------------------------
---------------MOD�LO DE BUSCA - IF -------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

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
        keep_simulating : in boolean := True; -- Sinal que indica a continuação da simulação
        -- Saída
        BID             : out std_logic_vector(63 downto 0) := x"0000000000000000" -- Reg. de saída if para id
    );
end entity;

architecture behav of estagio_if is

    -- Componentes necessários 
    component d_register is 
        generic(
            constant N  : integer := 8
        );
        port(
            clock   : in std_logic;
            reset   : in std_logic;
            load    : in std_logic;
            D       : in std_logic_vector(N-1 downto 0);
            Q       : out std_logic_vector(N-1 downto 0) := (others => '0')
        );
    end component;

    component mux2 is
        generic(width: integer := 8);
        port(
            d0, d1 : in STD_LOGIC_VECTOR(width-1 downto 0);
            s      : in STD_LOGIC;
            y      : out STD_LOGIC_VECTOR(width-1 downto 0) := (others => '0')
        );
    end component;

    component mux4 is
        generic(width: integer := 8);
        port(
            d0, d1, d2, d3 : in STD_LOGIC_VECTOR(width-1 downto 0);
            s      : in STD_LOGIC_VECTOR(1 downto 0);
            y      : out STD_LOGIC_VECTOR(width-1 downto 0) := (others => '0')
        );
    end component;

    component adder is
        port(
            A, B    : in std_logic_vector(31 downto 0);
            sum     : out std_logic_vector(31 downto 0)
        );
    end component;
    
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

    signal s_reset, s_load_reg : std_logic;
    signal s_mux_src_pc : std_logic_vector(1 downto 0) := "00";
    signal s_instruction : std_logic_vector(31 downto 0);
    signal ri_if : std_logic_vector(31 downto 0);
    signal s_PC  : std_logic_vector(31 downto 0) := x"00000000";
    signal s_pc_plus_4  : std_logic_vector(31 downto 0);
    signal s_pc_mux  : std_logic_vector(31 downto 0);
    signal COP_IF : instruction_type := NOP;

begin

    -- Como foi inserido o endereço de interrupção/exceção?
    -- O endereço de interrupção é uma das entradas do mux que determina qual o PC a ser usado, é selecionado a partir do sinal id_Branch_nop
    -- Já o endereço de exceção foi implementado como sujerido no enunciado, o endereço 0x00000400 e é selecionado pelo sinal id_PC_src

    pc_src_mux: mux4
        generic map(
            width => 32
        )
        port map(
            d0 => s_pc_plus_4, -- PC + 4
            d1 => s_PC, -- PC
            d2 => id_Jump_PC, -- endereço de JUMP
            d3 => x"00000400", -- endereco de exceção, 
            s  => s_mux_src_pc,
            y  => s_pc_mux
        );

    s_mux_src_pc <= "10" when id_Branch_nop = '1' else
                    "11" when id_PC_src = '1' else
                    "01" when id_hd_hazard = '1' else
                    "00";

    -- Como se implementou a preservação do valor do PC?
    -- O valor de PC é preservado ao desligar o load do registrador PC. Isso é feito também usando o sinal
    -- id_hd_hazard. Se teve hazard, o registrador não deve salvar a entrada, do contrário ele salva
    
    pc_reg: d_register
        generic map(
            N => 32
        )
        port map(
            clock   => clock,
            reset   => s_reset,
            load    => s_load_reg,
            D       => s_pc_mux,
            Q       => s_PC
        );

    s_reset <= '0' when keep_simulating else '1';
    s_load_reg <= not id_hd_hazard;

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

    -- Como se implementou a inserção de NOPs?
    -- o ri_mux decide a inserção de NOPs usando como entradas a instrução lida ou o NOP e o seletor do mux
    -- é o sinal id_hd_hazard. Ou seja, tem hazard? Sim, então é NOP. Não, então é a instrução lida

    ri_mux: mux2
        generic map(
            width => 32
        )
        port map(
            d0 => s_instruction, -- instrução
            d1 => x"00000000", -- NOP
            s  => id_hd_hazard,
            y  => ri_if
        );

    -- Adicionando 4 ao PC
    adder_inst: adder
        port map(
            A   => s_PC,
            B   => x"00000004",
            sum => s_pc_plus_4
        );
    COP_IF <= decode(ri_if);
    BID <= s_PC & ri_if;

end behav;
