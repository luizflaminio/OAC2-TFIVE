---------------------------------------------------------------------------------------------------
-----------MODULO ESTAGIO DE MEMORIA---------------------------------------------------------------
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 

library work;
use work.tipos.all;	

-- O estágio de memória é responsável por implementar os acessos a memória de dados nas 
-- instruções de load e Store.
-- Nas demais instruções este estágio nao realiza nenhuma operação e passa simplesmente 
-- os dados recebidos para o estágio wb de forma a viabilizar
-- o armazenamento das informações nos registradores do Banco de registradores.
-- Os sinais de entrada e saída deste estágio encontram-se definidos na declaração da 
-- entidade estagio_mem.

entity estagio_mem_grupo10 is
    generic(
        dmem_init_file: string := "dmem.txt"		  		-- Arquivo inicializar a memória de dados
    );
    port(
		-- Entradas
		clock		: in std_logic;						 	-- Base de tempo
        BMEM		: in std_logic_vector(115 downto 0); 	-- informações vindas do estágio ex
		COP_mem		: in instruction_type;					-- Mnemônico sendo processada no estágio mem
		
		-- saídas
        BWB			: out std_logic_vector(103 downto 0) := (others => '0');-- informações para o wb
		COP_wb 		: out instruction_type := NOP;			-- Mnemônico a ser processada pelo estágio wb
		RegWrite_mem: out std_logic;						-- Escrita em regs no estágio mem
		MemRead_mem	: out std_logic;						-- Leitura da memória no estágio mem 
		MemWrite_mem: out std_logic;						-- Escrita na memoria de dados no estágio mem
		rd_mem		: out std_logic_vector(004 downto 0);	-- Destino nos regs. no estagio mem
		ula_mem		: out std_logic_vector(031 downto 0);	-- ULA no estágio mem para o estágio mem
		NPC_mem		: out std_logic_vector(031 downto 0);	-- Valor do NPC no estagio mem
		Memval_mem	: out std_Logic_vector(031 downto 0)	-- Saida da memória no estágio mem
		
    );
end entity;

architecture behav of estagio_mem_grupo10 is

	component data_ram is 
		generic(
			address_bits		: integer 	:= 32;		  -- Bits de end. da mem�ria de dados
			size				: integer 	:= 4099;	  -- Tamanho da mem�ria de dados em Bytes
			data_ram_init_file	: string 	:= "dmem.txt" -- Arquivo da mem�ria de dados
		);
		port (
		-- Entradas
			clock 		: in  std_logic;							    -- Base de tempo bancada de teste
			write 		: in  std_logic;								-- Sinal de escrita na mem�ria
			address 	: in  std_logic_vector(address_bits-1 downto 0);-- Entrada de endere�o da mem�ria
			data_in 	: in  std_logic_vector(address_bits-1 downto 0);-- Entrada de dados da mem�ria

		-- Sa�da
			data_out 	: out std_logic_vector(address_bits-1 downto 0)	-- Sa�da de dados da mem�ria
		);
	end component;

	signal MemToReg		: std_logic_vector(1 downto 0); -- vai pro WB
	signal s_RegWrite_mem	: std_logic; -- usa aqui
	signal s_MemWrite_mem	: std_logic; -- usa aqui
	signal s_MemRead_mem	: std_logic; -- usa aqui
	signal s_NPC_mem		: std_logic_vector(31 downto 0); -- usa aqui e WB
	signal s_ula_mem		: std_logic_vector(31 downto 0); -- usa aqui e WB
	signal dado_rs2_sw	: std_logic_vector(31 downto 0); -- usa aqui
	signal rs1_mem		: std_logic_vector(4 downto 0); -- nao usa
	signal rs2_mem		: std_logic_vector(4 downto 0); -- nao usa
	signal s_rd_mem		: std_logic_vector(4 downto 0); -- usa aqui e WB
	signal s_Memval_mem	: std_logic_vector(31 downto 0); -- usa aqui e WB

	begin

	set_signals: process(BMEM)
	begin
		MemToReg <= BMEM(115 downto 114);
		s_RegWrite_mem <= BMEM(113);
		s_MemWrite_mem <= BMEM(112);
		s_MemRead_mem <= BMEM(111);
		s_NPC_mem <= BMEM(110 downto 79);
		s_ula_mem <= BMEM(78 downto 47);
		dado_rs2_sw <= BMEM(46 downto 15);
		rs1_mem <= BMEM(14 downto 10);
		rs2_mem <= BMEM(9 downto 5);
		s_rd_mem <= BMEM(4 downto 0);
	end process;

	-- sinais de saída desse estágio
	RegWrite_mem <= s_RegWrite_mem;
	MemRead_mem <= s_MemRead_mem;
	MemWrite_mem <= s_MemWrite_mem;
	rd_mem <= s_rd_mem;
	ula_mem <= s_ula_mem;
	NPC_mem <= s_NPC_mem;
	Memval_mem <= s_Memval_mem;

	process(clock)
	begin
		if rising_edge(clock) then
			COP_wb <= COP_mem;
			-- ver quais os endereços que vão cada um dos sinais dentro do BWB
			BWB(103 downto 102) <= MemToReg; -- seletor mux WB
			BWB(101) <= RegWrite_mem; -- escrita regs para o ID
			BWB(100 downto 69) <= NPC_mem; -- possivel dado para o WB
			BWB(68 downto 37) <= ula_mem; -- possivel dado para o WB
			if MemRead_mem = '1' then
				BWB(36 downto 5) <= s_Memval_mem; -- possivel dado para o WB
			else 
				BWB(36 downto 5) <= x"00000000";
			end if;
			BWB(4 downto 0) <= s_rd_mem; -- endereço de escrita no ID
		end if;
	end process;

	ram: data_ram
		generic map(
			address_bits		=> 32,
			size				=> 4099,
			data_ram_init_file	=> data_ram_init_file
		)
		port map(
			clock		=> clock,
			write		=> MemWrite_mem,
			address		=> ula_mem,
			data_in		=> dado_rs2_sw,
			data_out	=> s_Memval_mem
		);
end architecture;