entity estagio_if is
    port(
        -- Entradas
        clock           : in std_logic; -- Base de tempo vinda da bancada de teste
        id_PC_Src       : in std_logic; -- Determina a escolha da entrada do PC
        id_interruption : in std_logic; -- Determina se houve uma exceção ou interrupção
        id_pc_target    : in std_logic_vector(31 downto 0); -- O valor do próximo endereço de instrução em caso de desvios
        hd_flush        : in std_logic; -- Determina se caso a saída ri_if será lida na memória de instrução ou será zerada.
        hd_stall_f      : in std_logic; -- Responsável pela não atualização do PC em caso de bolhas
        -- Saidas
        BID             : out std_logic_vector(63 downto 0) -- Reg. de saída do estagi_if para estagi_id
    );
end entity;
