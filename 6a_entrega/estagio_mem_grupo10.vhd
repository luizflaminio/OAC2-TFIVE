---------------------------------------------------------------------------------------------------
-----------MODULO ESTAGIO DE MEMORIA---------------------------------------------------------------
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 

library work;
use work.tipos.all;	

-- O est�gio de mem�ria � respons�vel por implementar os acessos a mem�ria de dados nas 
-- instru�oes de load e Store.
-- Nas demais instru�oes este est�gio nao realiza nenhuma opera�ao e passa simplesmente 
-- os dados recebidos para o est�gio wb de forma a viabilizar
-- o armazenamento das informa�oes nos registradores do Banco de registradores.
-- Os sinais de entrada e sa�da deste est�gio encontram-se definidos na declara�ao da 
-- entidade estagio_mem.

entity estagio_mem_grupo10 is
    generic(
        dmem_init_file: string := "dmem.txt"		  		-- Arquivo inicializar a mem�ria de dados
    );
    port(
		-- Entradas
		clock		: in std_logic;						 	-- Base de tempo
        BMEM		: in std_logic_vector(115 downto 0); 	-- Informa�oes vindas do est�gio ex
		COP_mem		: in instruction_type;					-- Mnem�nico sendo processada no est�gio mem
		
		-- Sa�das
        BWB			: out std_logic_vector(103 downto 0) := (others => '0');-- Informa�oes para o wb
		COP_wb 		: out instruction_type := NOP;			-- Mnem�nico a ser processada pelo est�gio wb
		RegWrite_mem: out std_logic;						-- Escrita em regs no est�gio mem
		MemRead_mem	: out std_logic;						-- Leitura da mem�ria no est�gio mem 
		MemWrite_mem: out std_logic;						-- Escrita na memoria de dados no est�gio mem
		rd_mem		: out std_logic_vector(004 downto 0);	-- Destino nos regs. no estagio mem
		ula_mem		: out std_logic_vector(031 downto 0);	-- ULA no est�go mem para o est�gio mem
		NPC_mem		: out std_logic_vector(031 downto 0);	-- Valor do NPC no estagio mem
		Memval_mem	: out std_Logic_vector(031 downto 0)	-- Saida da mem�ria no est�gio mem
		
    );
end entity;