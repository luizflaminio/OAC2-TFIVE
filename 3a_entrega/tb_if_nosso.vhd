----------------------------------------------------------------------------------------------------------------------------------
-------------------------------Bancada de teste do estagio de Busca - rotina swap modificada--------------------------------------
----------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
 
entity tb_if is
end entity; 

architecture tb of tb_if is
component estagio_if is
    generic(
        imem_init_file: string := "imem.txt"
    );
    port(
        --Entradas
        clock 			: in  	std_logic;	-- Base de tempo vinda da bancada de teste
        id_hd_hazard	: in 	std_logic;	-- Sinal de controle que carrega 0's na parte do RI do registrador de sa�da do if_stage
				id_Branch_nop	: in 	std_logic;	-- Sinal que indica inser4�ao de NP devido a desviou pulo
				id_PC_Src		: in 	std_logic;	-- Sele�ao do mux da entrada do PC
				id_Jump_PC		: in 	std_logic_vector(31 downto 0);			-- Endereco do Jump ou desvio realizado
				keep_simulating	: in	Boolean := True;
			
			-- Saida
        BID				: out 	std_logic_vector(63 downto 0) := x"0000000000000000"	--Registrador de sa�da do if_stage-if_id
    );
end component;

	constant clock_period	  : time 		:= 10 ns;
	signal clock			      : std_logic := '1';
	signal BID				      : std_logic_vector (63 downto 0); 
	signal id_hd_hazard		  : std_logic;
	signal id_Branch_nop	  : std_logic;
	signal id_PC_Src		    : std_logic;
	signal id_Jump_PC		    : std_logic_vector(31 downto 0);
	signal Keep_simulating	: boolean 	:= true;

begin
    clock <= not clock after clock_period / 2;

    DUT: estagio_if 
        generic map (
            imem_init_file => "imem.txt"
        ) port map (
          --Entradas
          clock           => clock,			-- Base de tempo vinda da bancada de teste
          id_hd_hazard		=> id_hd_hazard,	-- Sinal de controle que carrega 0's na parte do RI do registrador de sa�da do if_stage
          id_Branch_nop		=> id_Branch_nop,	-- Sinal que indica inser4�ao de NP devido a desviou pulo
          id_PC_Src			  => id_PC_Src,		-- Sele�ao do mux da entrada do PC
          id_Jump_PC		  => id_Jump_PC,		-- Endere�o do Jump ou desvio realizado
          keep_simulating	=> keep_simulating,	-- Continue a simula�ao

          -- Saida
          BID  => BID  --Registrador de sa�da do if_stage-if_id
        );

    stim: process is
    begin
        id_hd_hazard 	  <= '0';			    -- Nao insere NOP
				id_Branch_nop 	<= '0';		   	  -- Nao sinaliza Jump
				id_PC_Src 		  <= '0';		      -- Nao é instrucao de desvio ou pulo
				id_Jump_PC 		  <= x"00000000"; -- Se tiver que pular o próximo endere�o ser� x"00000000"
				keep_simulating <= true;		    -- Mantenha simulacao ativa 
		
		wait for clock_period;		 -- ciclo 1 = 0 ns espera um ciclo de relogio 
		
		-- Situação no instante 10 ns
		report "Testando se instrucao na posicao 1 esta correta";
		assert BID(31 downto 00) = x"00000513" severity error;	 	-- Testa se esta instrucao eh: addi	a0,	zero,0
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 	  -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000000"  severity error;	 	-- Testa se PC = x"00000000
		report "PC_id = " & to_hex_string(BID(63 downto 32));	 	  -- Imprime o valor que esta no PC_id
		report " " ;											 	-- Pula uma linha no conslole de sa�da
	   
		-- Situação no instante 20 ns
		wait for clock_period;		 -- ciclo 2 = 20 ns	  leitura da 2a. instrucao do swap
		report "Testando se instrucao na posicao 2 (em palavras) esta correta";
		assert BID(31 downto 00) = x"00300593" severity error; 	 	-- Testa se esta instrucao eh: addi	a0,	zero,3
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 	  -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";					 	  
		assert BID(63 downto 32) = x"00000004" severity error;	 	-- Testa se PC = x"00000004"
		report " PC_id = " & to_hex_string(BID(63 downto 32)); 	 	-- Imprime o valor que esta no PC		o
		report " " ;											 	-- Pula uma linha no console de saida
		
        -- Situação no instante 30 ns
		wait for clock_period;		  -- ciclo 3 = 30 ns	leitura da 3a. instrucao do swap
		report "Testando se instrucao na posicao 3 esta correta";
		assert BID(31 downto 00) = x"00259293" severity error;	 -- Testa se a instrucao eh: slli t0, a1, 2 
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000008" severity error;	 -- Testa se PC = x"00000008"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida
		
		-- Situação no instante 40 ns
		wait for clock_period;		  -- ciclo 4 = 40 ns	leitura da 4a. instrucao do swap
		report "Testando se instrucao na posicao 4 esta correta";
		assert BID(31 downto 00) = x"005502B3" severity error; 	 -- Testa se a instrucao eh: add t0,a0,t0
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"0000000C" severity error; 	 -- Testando se PC = x"0000000C"
		report " PC_id = " & to_hex_string(BID(63 downto 32)); 	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida
		
		-- Situação no instante 50 ns
		wait for clock_period;		  -- ciclo 5 = 50 ns	leitura da 5a. instrucao do swap
		report "Testando se instrucao na posicao 5 esta correta";
		assert BID(31 downto 00) = x"0002A303" severity error;	 -- Testa se a instrucao eh: lw t1, 0(t0)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000010" severity error;	 -- Testa se PC = x"00000010"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida
		
		-- Situação no instante 60 ns
		wait for clock_period;		   -- ciclo 6 = 60 ns	leitura da 6a. instrucao do swap
		report "Testando se instrucao na posicao 6 esta correta";
		assert BID(31 downto 00) = x"0042A383" severity error;	 -- Testa se a instrucao eh: lw t2, 4(t0)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000014" severity error;	 -- Testa se PC = x"00000014"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida
		
		 -- Situação no instante 70 ns
		wait for clock_period;		   -- ciclo 7 = 70 ns	leitura da 7a. instrucao do swap
		report "Testando se instrucao na posicao 7 esta correta";
		assert BID(31 downto 00) = x"0072A023" severity error;	 -- Testa se a instrucao eh: sw t2, 0(t0) 
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000018" severity error; 	 -- Testa se PC = x"00000018"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida
		
		-- Situação no instante 80 ns
		wait for clock_period;		   -- ciclo 8 = 80 ns	leitura da 8a. instrucao do swap
		report "Testando se instrucao na posicao 8 esta correta";
		assert BID(31 downto 00) = x"0062A223" severity error;	 -- Testa se a instrucao eh: sw t1, 4(t0)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"0000001C" severity error;	 -- Testa se PC = x"0000001C"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida
		
		-- Situação no instante 90 ns
		wait for clock_period;		   -- ciclo 9 = 90 ns	leitura da 9a. instrucao do swap
		report "Testando se instrucao na posicao 9 esta correta";
		assert BID(31 downto 00) = x"00001013" severity error;	 -- Testa se a instrucao eh: slli zero, zero, 0 (NOP)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000020" severity error; 	 -- Testa se PC = x"00000020"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida 
		
		
		id_Jump_PC 		<= x"00000040"; -- Se tiver que pular o proximo endereco sera x"00000040"
		wait for clock_period/2;
		report "Definido endereco de jump para 0x00000040";
		-- Situação no instante 95 ns
		
		
		-- Situação no instante 100 ns
		wait for clock_period/2;   		 -- ciclo 10 = 100 ns	 Teste de desvio inserindo endereco destino no PC 
		report "Testando se instrucao na posicao 10 esta correta";
		assert BID(31 downto 00) = x"00001013" severity error; 	 -- A instrucao ainda eh:	slli zero,zero, 0
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000024" severity error;	 -- Testa se PC = x"00000024"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida
		
		-- Situação no instante 105 ns
		id_Branch_nop <= '1';	  -- ativa insercao de NOP no ri_if e BID
		wait for clock_period/2;
		report "Sinal de JUMP ligado";
		
		-- Situação no instante 110 ns
		wait for clock_period/2;		  -- ciclo 11 = 110 ns	 Teste de desvio lendo o endereco destino no PC
		report "Testando se instrucao na posicao 11 esta correta";
		assert BID(31 downto 00) = x"00001013" severity error; 	 -- A instrucao ainda eh:	slli zero,zero, 0
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000028" severity error; 	 -- Testa se PC = x"00000028"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida
		
		-- Situação no instante 115 ns
		id_Branch_nop <= '0';	  -- ativa insercao de NOP no ri_if e BID
		wait for clock_period/2;
		report "Sinal de JUMP desligado";
		
		-- Situação no instante 120 ns
		wait for clock_period/2;		  -- ciclo 12 = 120 ns	 Teste se esta inserindo NOP no ri e BID
		report "Testando se instrucao na posicao 17 esta correta";
		assert BID(31 downto 00) = x"000001013" severity error; 	 -- A instrucao eh:	slli zero,zero, 0
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 	-- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000040" severity error; 	 	-- Testa se PC = x"00000040"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 	-- Imprime o valor que esta no PC
		report " " ;											 	-- Pula uma linha no console de saida	
		
		-- Situação no instante 125 ns
		id_hd_hazard <= '1';	 -- Desativa insercao de NOP
		wait for clock_period/2;
		report "Sinal de HAZARD ligado";
		
		-- Situação no instante 130 ns
		wait for clock_period/2;		  -- ciclo 13 = 130 ns	 Teste se est� inserindo NOP no ri e BID
		report "Testando se NOP foi inserido corretamente";
		assert BID(31 downto 00) = x"00000000" severity error; 	-- A instrucao eh: NOP (x"000000000" é visto como NOP)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 	-- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000044" severity error; 	 	-- Testa se manteve o PC = x"00000044"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 	-- Imprime o valor que esta no PC
		report " " ;											 	-- Pula uma linha no console de saida
		
		-- Situação no instante 135 ns
		id_hd_hazard <= '0';	-- Ativa deteccao de conflito 
		wait for clock_period/2;
		report "Sinal de HAZARD desligado";
		
		-- Situação no instante 140 ns
		wait for clock_period/2;		  -- ciclo 14 = 140 ns	 Teste de deteccao de conflito com acionamento do id_hd_Hazrd
		report "Testando se instrucao na posicao 18 esta correta";
		assert BID(31 downto 00) = x"00000000" severity error; 	 -- A instrucao eh: NOP (x"000000000" é visto como NOP)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000044" severity error; 	 -- Testa se manteve o PC = x"00000040"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida	
		
		-- Situação no instante 145 ns
		wait for clock_period;		  -- ciclo 14 = 150 ns	 Teste de deteccao de conflito sendo desativada
		report "Testando se instrucao na posicao 19 esta correta";
		assert BID(31 downto 00) = x"00000000" severity error; 	 -- A instrucao eh: NOP (x"000000000" é visto como NOP)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000048" severity error; 	 -- Testa se manteve o PC = x"00000048"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida	

		-- Situação no instante 155 ns
		id_PC_src <= '1';	-- Ativa deteccao de interrupção
		wait for clock_period/2;
		report "Sinal de HALT ligado";
		
		-- Situação no instante 160 ns
		wait for clock_period/2;		  -- ciclo 15 = 160 ns	 Teste de deteccao de conflito com acionamento do id_hd_Hazrd
		report "Testando se instrucao na posicao 20 esta correta";
		assert BID(31 downto 00) = x"00000000" severity error; 	 -- A instrucao eh: NOP (x"000000000" é visto como NOP)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"0000004C" severity error; 	 -- Testa se manteve o PC = x"0000004C"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida	

		-- Situação no instante 165 ns
		id_PC_src <= '0';	-- Desativa deteccao de interrupção
		wait for clock_period/2;
		report "Sinal de HALT desligado";
		
		-- Situação no instante 170 ns
		wait for clock_period/2;		  -- ciclo 16 = 170 ns	 Teste de deteccao de conflito com acionamento do id_hd_Hazrd
		report "Testando se instrucao na posicao 257 esta correta";
		assert BID(31 downto 00) = x"0000006F" severity error; 	 -- A instrucao eh: hal zero, 0; HALT
		report "RI_if = " & to_hex_string(BID(31 downto 00));	   -- Imprime o codigo da instrucao passada para o id
		report "Testando o valor do PC enviado para o estagio id";
		assert BID(63 downto 32) = x"00000400" severity error; 	 -- Testa se manteve o PC = x"0000004C"
		report " PC_id = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no console de saida	

		-- Como foi parada a simulação quando este estágio encontrar a instrução Halt?
		-- Inicialmente escrevemos a instrução HALT na posição de exceção na memória RAM.
		-- É feito um assert que para a execução quando chega na instrução de HALT ao final da simulação

		assert not (BID(31 downto 00) = x"0000006F") severity failure;
    end process;
end tb;   
