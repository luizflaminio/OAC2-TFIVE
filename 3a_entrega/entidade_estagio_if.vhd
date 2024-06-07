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
        imem_init_file: string := "imem.txt"	--Nome do arquivo com o conteúdo da memoria de programa
    );
    port(
			--Entradas
			clock			    : in 	std_logic;	-- Base de tempo vinda da bancada de teste
      id_hd_hazard	: in 	std_logic;	-- Sinal de controle que carrega 0's na parte do RI do  registrador de saída BID
			id_Branch_nop	: in 	std_logic;	-- Sinal que determina inserçao de NOP- desvio ou pulo
			id_PC_Src		  : in 	std_logic;	-- Seleçao do mux da entrada do PC
			id_Jump_PC		: in 	std_logic_vector(31 downto 0) := x"00000000";	-- Endereço do Jump ou desvio realizado
			keep_simulating	: in	Boolean := True; -- Sinal que indica a continuaçao da simulaçao
			-- Saída
      BID				: out 	std_logic_vector(63 downto 0) := x"0000000000000000"--Reg. de saída if para id
    );
end entity;

architecture behav of estagio_if is

	signal 

begin

end behav ; -- behav