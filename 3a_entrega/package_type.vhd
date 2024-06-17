---------------------------------------------------------------------------------------
----------Pacote para declara�ao do tipo de instru�oes---------------------------------
---------------------------------------------------------------------------------------

-- Sessao de daclara�ao do package de tipos de instru�oes
	package tipos is
		--tipo e mnem�nicos de instru�ao
    type instruction_type is (ADD, SLT,                     --tipo R
                              ADDI, SLTI, SLLI, SRLI, SRAI, --tipo I
                              LW,                           --tipo load
                              SW,                           --tipo Store
                              BEQ, BNE, BLT,                --tipo Branchs
                              JAL, JALR,                 	--tipo Jumps
							  NOP,							--tipo inventado
							  NOINST,						--tipo nao existente 
							  HALT							--PARE
		);	
	end package tipos;

	