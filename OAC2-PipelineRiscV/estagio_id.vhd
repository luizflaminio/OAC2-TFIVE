library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;

entity estagio_id is
    port(
        -- Entrada
        clock           : in  std_logic; -- Sinal de clock que vem do testbench
        reset           : in std_logic; -- Reset dos componentes do estágio
        instruction     : in  std_logic_vector(31 downto 0); -- Instrução vinda do estágio IF
        pc              : in  std_logic_vector(31 downto 0); -- Valor do PC da instrução vinda do estágio IF
        reg_write_w     : in  std_logic; -- Determina se a instrução que está no estágio WB deve escrever no banco de registradores
        write_addr_w    : in  std_logic_vector(4 downto 0); -- Endereço do registrador que a instrução em WB irá escrever
        write_data_w    : in  std_logic_vector(31 downto 0); -- Dado a ser escrito no banco de registradores
        -- Detecção de hazards
        reg_source_id1  : in std_logic_vector(4 downto 0); -- Endereço de origem 1, do registrador de estágio EX
        reg_source_id2  : in std_logic_vector(4 downto 0); -- Endereço de origem 2, do registrador de estágio EX
        reg_destin_ex   : in std_logic_vector(4 downto 0); -- Sinaliza se a instrução em EX é uma leitura de memória
        mem_read_ex     : in std_logic; -- Determina se a instrução que está no estágio WB deve escrever no banco de registradores
        -- Desvios
        forward_id      : in std_logic_vector(1 downto 0); -- Sinaliza se há encaminhamento e qual registrador tem conflito
        alu_result_ex   : in  std_logic_vector(31 downto 0); -- Dado que deve ser considerado para o cálculo de desvio ou salto
        -- Saída
        bex             : out std_logic_vector(308 downto 0) -- Dadso do estágio ID para o estágio EX
    );
end entity estagio_id;

