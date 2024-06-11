---------------------------------------------------------------------------------------------------------
---------------MOD�LO DE BUSCA - IF -------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

library work;
use work.tipos.all;

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

    component mux3 is
        generic(
            width   : integer
        );
        port(
            d0, d1, d2 : in std_logic_vector(width-1 downto 0);
            s           : in std_logic_vector(1 downto 0);
            y           : out std_logic_vector(width-1 downto 0)
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

    signal s_pc_enable, s_reset : std_logic;
    signal s_pc_src_mux_s : std_logic_vector(1 downto 0) := "00";
    signal s_instruction : std_logic_vector(31 downto 0);
    signal s_PC  : std_logic_vector(31 downto 0) := x"00000000";
    signal s_pc_plus_4  : std_logic_vector(31 downto 0);
    signal s_pc_mux  : std_logic_vector(31 downto 0);

begin
    
    pc_src_mux: mux3
        generic map(
            width => 32
        )
        port map(
            d0 => s_pc_plus_4, -- PC + 4
            d1 => id_Jump_PC, -- endereço de JUMP
            d2 => x"00000020", -- endereço do NOP
            s  => s_pc_src_mux_s,
            y  => s_pc_mux
        );

    s_pc_src_mux_s <= "10" when id_Branch_nop = '1' else 
                      "01" when id_PC_Src = '1' else
                      "00";

    pc_plus_4_reg: d_register
        generic map(
            N => 32
        )
        port map(
            clock   => clock,
            reset   => s_reset,
            load    => '1',
            D       => s_pc_mux,
            Q       => s_PC
        );

    s_reset <= '0' when keep_simulating else '1';

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

    -- Adicionando 4 ao PC
    adder_inst: adder
        port map(
            A   => s_PC,
            B   => x"00000004",
            sum => s_pc_plus_4
        );

    -- Processo para atualizar o BID
    process(clock)
    begin
        if rising_edge(clock) then
            if keep_simulating then
                    BID <= s_PC & s_instruction; -- Concatenação da instrução e PC
            end if;
        end if;
    end process;

end behav;
