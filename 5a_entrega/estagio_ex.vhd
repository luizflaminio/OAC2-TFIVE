----------------------------------------------------------------------------------------------------
-------------MODULO ESTAGIO DE EXECU�AO-------------------------------------------------------------
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

library work;
use work.tipos.all;

-- Especifica�ao do estagio Executa - ex: declara�ao de entidade
-- Neste est�gio sao executadas as instru�oes do tipo RR e calculado os endere�os 
-- das instru�oes de load e store.
-- O m�dulo que implementa a antecipa�ao de valores (Forwarding) � feita neste est�gio 
-- num m�dulo separado dentro do est�gio ex.
-- A unidade l�gica e aritm�tica - ULA - fica neste est�gio.
-- Os multiplexadores de estrada da ULA que selecionam os valores corretos dependendo 
-- da antecipa�ao ficam neste est�gio.
-- A defini�ao do sinais de entrada e sa�da do est�gio EX encontram-se na declara�ao 
-- da entidade est�gio_ex e sao passados pelo registrador BEX

entity estagio_ex is
    port(
		-- Entradas
		clock				: in 	std_logic;					  		-- Rel�gio do Sistema
      	BEX					: in 	std_logic_vector (151 downto 0);  	-- Dados vindos do id
		COP_ex				: in 	instruction_type;				  	-- Mnem�nico no est�gio ex
		ula_mem				: in 	std_logic_vector (031 downto 0);	-- ULA no est�gio de Mem�ria
		rs1_id_ex			: in	std_logic_vector (004 downto 0);    -- rs1 no est�gio id para o ex
		rs2_id_ex			: in	std_logic_vector (004 downto 0);    -- rs2 no est�gio id para o ex
		MemRead_mem			: in 	std_logic;					  		-- Leitura na mem�ria no  mem
		RegWrite_mem		: in 	std_logic;					  		-- Escrita nos regs. no  mem
		rd_mem				: in 	std_logic_vector (004 downto 0);	-- Destino nos regs. mem
		RegWrite_wb			: in	Std_logic;							-- Escrita nos regs no estagio wb
		rd_wb				: in	std_logic_vector (004 downto 0);	-- Destino no rges no est�gio wb
		writedata_wb		: in 	std_logic_vector (031 downto 0);	-- Dado a ser escrito no regs.
		Memval_mem			: in	std_logic_vector (031 downto 0);	-- Sa�da da mem�ria no mem
		
		-- Sa�das
		MemRead_ex			: out	std_logic;							-- Leitura da mem�ria no ex 
		rd_ex				: out	std_logic_vector (004 downto 0);	-- Destino dos regs no ex
		ULA_ex				: out	std_logic_vector (031 downto 0);	-- ULA no est�gio ex
		ex_fw_A_Branch		: out 	std_logic_vector (001 downto 0);	-- Dado comparado em A no id 
																		-- em desvios com forward
        ex_fw_B_Branch		: out 	std_logic_vector (001 downto 0);	-- Dado comparado em B no id 
																		-- em desvios com forward
        BMEM				: out 	std_logic_vector (115 downto 0) := (others => '0'); -- dados para mem
		COP_mem				: out 	instruction_type := NOP			  	-- Mnem�nico no est�gio mem
		
		);
end entity;