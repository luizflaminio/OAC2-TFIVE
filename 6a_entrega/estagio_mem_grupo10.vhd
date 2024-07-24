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

architecture behavioral of estagio_mem_grupo10 is
	component ram is
        generic(
            address_bits    : integer := 32; -- Número de bits de endereço da memória
            size            : integer := 4096; -- Tamanho da memória em bytes
            ram_init_file   : string := "dmem.txt" -- Arquivo que contém o conteúdo da memória
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

	signal mem_read, mem_write, reg_write: std_logic;
	signal mem_val, mem_data: std_logic_vector(31 downto 0);

	begin
		memory_control: process(BMEM)
			begin
				mem_read <= BMEM(111);
				mem_write <= BMEM(112);
				reg_write <= BMEM(113);
				mem_addr <= BMEM(78 downto 47);-- le-se do endereco calculado na ULA
				mem_data <= BMEM(46 downto 15);
			end process;

		dmem: ram
			generic map(
				address_bits    => 32,
				size            => 4096,
				ram_init_file   => dmem_init_file
			)
			port map(
				clock       => clock,
				write       => mem_write,
				address     => mem_addr,
				data_in     => mem_data,
				data_out    => mem_val
			);
end architecture behavioral;