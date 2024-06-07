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
			clock			: in 	std_logic;	-- Base de tempo vinda da bancada de teste
        	id_hd_hazard	: in 	std_logic;	-- Sinal de controle que carrega 0's na parte do RI do registrador de saída do if_stage
			id_Branch_nop	: in 	std_logic;	-- Sinal que indica inser4ção de NOP devido a desviou pulo
			id_PC_Src		: in 	std_logic;	-- Seleção do mux da entrada do PC
			id_Jump_PC		: in 	std_logic_vector(31 downto 0) := x"00000000";			-- Endereço do Jump ou desvio realizado
			keep_simulating	: in	Boolean := True;
			
			-- saída
        	BID				: out 	std_logic_vector(63 downto 0) := x"0000000000000000"	--Registrador de saída do if_stage-if_id
    );
end component;

	constant clock_period	: time 		:= 10 ns;
	signal clock			: std_logic := '1';
	signal PC_if			: std_logic_vector(31 downto 0);
	signal BID				: std_logic_vector (63 downto 0); 
	signal id_hd_hazard		: std_logic;
	signal id_Branch_nop	: std_logic;
	signal id_PC_Src		: std_logic;
	signal id_Jump_PC		: std_logic_vector(31 downto 0);
	signal Keep_simulating	: boolean 	:= true;

begin
    clock <= not clock after clock_period / 2;

    DUT: estagio_if 
        generic map(
            imem_init_file => "imem.txt"
        )
        port map(
            --Entradas
			clock			=> clock,			-- Base de tempo vinda da bancada de teste
        	id_hd_hazard	=> id_hd_hazard,	-- Sinal de controle que carrega 0's na parte do RI do registrador de saída do if_stage
			id_Branch_nop	=> id_Branch_nop,	-- Sinal que indica inser4ção de NP devido a desviou pulo
			id_PC_Src		=> id_PC_Src,		-- Seleção do mux da entrada do PC
			id_Jump_PC		=> id_Jump_PC,		-- Endereço do Jump ou desvio realizado
			keep_simulating	=> keep_simulating,	-- Continue a simulação
			
			-- saída
        	BID				=> BID				--Registrador de saída do if_stage-if_id
        );

    stim: process is
    begin
        id_hd_hazard 	<= '0';			-- Nao sinaliza conflito
		id_Branch_nop 	<= '0';		   	-- Nao insere NOP
		id_PC_Src 		<= '0';		    -- Nao é instrucao de desvio ou pulo
		id_Jump_PC 		<= x"00000000"; -- Se tiver que pular o próximo endereço será x"00000000"
		keep_simulating <= true;		-- Mantenha simulacao ativa 
		
		wait for clock_period;		 -- ciclo 1 = 0 ns	  espera um ciclo de relógio
		
        wait for clock_period;		 -- ciclo 1 = 20 ns	  inicia a leitura da 1a. instrucao do programa swap
        report "Testando se instrução na posição 0 está correta";
        assert BID(31 downto 00) = x"00000513" severity error;	 -- Testa se esta instrucao é: addi	a0,	zero,0
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina deveria ser = x"00000513"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000000"  severity error;	 -- Testa se PC = x"00000000
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída

        wait for clock_period;		 -- ciclo 2 = 30 ns	  leitura da 2a. instrucao do swap
        report "Testando se instrução na posição 1 (em palavras) está correta";
        assert BID(31 downto 00) = x"00300593" severity error; 	 -- Testa se a instrucao é: addi a1, zero,3 
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"00300593"
        report "Testando se saída tem PC+4";					 	  
        assert BID(63 downto 32) = x"00000004" severity error;	 -- Testa se PC = x"00000004"
		report " PC_if = " & to_hex_string(BID(63 downto 32)); 	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
        wait for clock_period;		  -- ciclo 3 = 40 ns	leitura da 3a. instrucao do swap
        report "Testando se instrução na posição 2 está correta";
        assert BID(31downto 00) = x"00259293" severity error;	 -- Testa se a instrucao é: slli t0, a1, 2 
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"00259293"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000008" severity error;	 -- Testa se PC = x"00000008"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
        wait for clock_period;		  -- ciclo 4 = 50 ns	leitura da 4a. instrucao do swap
        report "Testando se instrução na posição 3 está correta";
        assert BID(31 downto 00) = x"005502B3" severity error; 	 -- Testa se a instrucao é: add t0,a0,t0
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"005502B3"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"0000000C" severity error; 	 -- Testando se PC = x"0000000C"
		report " PC_if = " & to_hex_string(BID(63 downto 32)); 	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
        wait for clock_period;		  -- ciclo 5 = 60 ns	leitura da 5a. instrucao do swap
        report "Testando se instrução na posição 4 está correta";
        assert BID(31 downto 00) = x"0002A303" severity error;	 -- Testa se a instrucao é: lw t1, 0(t0)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"0002A303"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000010" severity error;	 -- Testa se PC = x"00000010"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
        wait for clock_period;		   -- ciclo 6 = 70 ns	leitura da 6a. instrucao do swap
        report "Testando se instrução na posição 5 está correta";
        assert BID(31 downto 00) = x"0042A383" severity error;	 -- Testa se a instrucao é: lw t2, 4(t0)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"0042A383"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000014" severity error;	 -- Testa se PC = x"00000014"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
        wait for clock_period;		   -- ciclo 7 = 80 ns	leitura da 7a. instrucao do swap
        report "Testando se instrução na posição 6 está correta";
        assert BID(31 downto 00) = x"0072A023" severity error;	 -- Testa se a instrucao é: sw t2, 0(t0) 
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"0072A023"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000018" severity error; 	 -- Testa se PC = x"00000018"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
        wait for clock_period;		   -- ciclo 8 = 90 ns	leitura da 8a. instrucao do swap
        report "Testando se instrução na posição 7 está correta";
        assert BID(31 downto 00) = x"0062A223" severity error;	 -- Testa se a instrucao é: sw t1, 4(t0)
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"0062A223"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"0000001C" severity error;	 -- Testa se PC = x"0000001C"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
        wait for clock_period;		   -- ciclo 9 = 100 ns	leitura da 9a. instrucao do swap
        report "Testando se instrução na posição 8 está correta";
        assert BID(31 downto 00) = x"00001013" severity error;	 -- Testa se a instrucao é: 
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"0000006F"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000020" severity error; 	 -- Testa se PC = x"00000020"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
		id_PC_Src <= '1';			   -- ciclo 10 = 110 ns	  Teste de desvio inserindo endereco destino no PC 
		id_Jump_PC 		<= x"00000040"; -- Se tiver que pular o próximo endereço será x"00000040"
		wait for clock_period;
        report "Testando se instrução na posição 9 está correta";
        assert BID(31 downto 00) = x"00001013" severity error; 	 -- A instrucao ainda é:	jalr zero, 0(ra) ou halt
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"00001013"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000024" severity error;	 -- Testa se PC = x"00000024"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
		id_PC_Src <= '0';
		wait for clock_period;		  -- ciclo 11 = 120 ns	 Teste de desvio lendo o endereco destino no PC
        report "Testando se instrução na posição 10 está correta";
        assert BID(31 downto 00) = x"00001013" severity error; 	 -- A instrucao ainda é:	jalr zero, 0(ra) ou halt
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"00001013"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000028" severity error; 	 -- Testa se PC = x"00000024"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
		id_Branch_nop <= '1'; id_PC_Src <= '1';	  -- ativa insercao de NOP no ri_if e BID
		wait for clock_period;		  -- ciclo 12 = 130 ns	 Teste se está inserindo NOP no ri e BID
        report "Testando se instrução inserida está correta posição 11";
        assert BID(31 downto 00) = x"000000000" severity error; 	 -- A instrucao é:	slli zero,zero, 0 == NOP
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"00001013"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000040" severity error; 	 -- Testa se PC = x"00000404"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída	
		
		id_Branch_nop <= '0'; id_PC_Src <= '0';	 -- Desativa insercao de NOP
		wait for clock_period;		  -- ciclo 13 = 140 ns	 Teste se está inserindo NOP no ri e BID
        report "Testando se instrução na posição 12 está correta";
        assert BID(31 downto 00) = x"00001013" severity error; 	 -- A instrucao é:	slli zero,zero, 0 == NOP
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"00001013"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000044" severity error; 	 -- Testa se manteve o PC = x"00000404"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída
		
		id_hd_hazard <= '1';	-- Ativa detccao de conflito
		wait for clock_period;		  -- ciclo 14 = 150 ns	 Teste de ceteccao de conflito com acionamento do id_hd_Hazrd
        report "Testando se instrução na posição 13 está correta";
        assert BID(31 downto 00) = x"00000000" severity error; 	 -- A instrucao ainda é: slli zero,zero, 0 == NOP
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"00001013"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000040" severity error; 	 -- Testa se manteve o PC = x"00000404"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída	
		
		id_hd_hazard <= '0';	-- Desativa detccao de conflito
		wait for clock_period;		  -- ciclo 15 = 160 ns	 Teste de deteccao de conflito sendo desativada
        report "Testando se instrução na posição 14 está correta";
        assert BID(31 downto 00) = x"00000000" severity error; 	 -- A instrucao ainda é: slli zero,zero, 0 == NOP
		report "RI_if = " & to_hex_string(BID(31 downto 00));	 -- Este é o código de máquina no ri_if = x"00001013"
        report "Testando se saída tem PC+4";
        assert BID(63 downto 32) = x"00000040" severity error; 	 -- Testa se manteve o PC = x"00000404"
		report " PC_if = " & to_hex_string(BID(63 downto 32));	 -- Imprime o valor que esta no PC
		report " " ;											 -- Pula uma linha no conslole de saída	

        wait;
    end process;
end tb;   
