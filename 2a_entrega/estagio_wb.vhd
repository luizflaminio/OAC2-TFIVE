entity estagio_wb is
    port(
        clock       : in std_logic;                       -- sinal de clock
        result_src  : in std_logic_vector(1 downto 0);    -- sinal de controle do MUX  
        alu_result  : in std_logic_vector(31 downto 0);   -- valor na saída da ULA
        pc_plus_4   : in std_logic_vector(31 downto 0);   -- Ponteiro para a próxima instrução
        read_data   : in std_logic_vector(31 downto 0);   -- Valor na memória que veio do registrador lido
        -- Saídas
        reg_write   : out std_logic;                      -- sinal de enable para escrever ou não no registrador
        write_addrW : out std_logic_vector(4 downto 0);   -- endereço do registrador que deve guardar o valor lido
        result_w    : out std_logic_vector(31 downto 0);  -- Saída do multiplexador
    );
end entity;