entity estagio_mem is
    port(
        -- Entradas
        clock       : in std_logic;                       -- sinal de clock
        reg_write   : in std_logic;                       -- sinal que habilita escrita no registrador
        mem_write   : in std_logic;                       -- sinal que habilita leitura na memória
        result_src  : in std_logic_vector(1 downto 0);    -- controle do multiplexador do estado wb
        alu_result  : in std_logic_vector(31 downto 0);   -- sinal de saída da ULA
        write_data  : in std_logic_vector(31 downto 0);   -- Palavra de entrada da memória
        rd          : in std_logic_vector(4 downto 0);    -- Registrador de destino
        pc_plus_4   : in std_logic_vector(31 downto 0);   -- Próxima instrução (PC + 4)
        -- Saídas
        bwb         : out std_logic_vector(106 downto 0)  -- Buffer de saída
    );
end entity;