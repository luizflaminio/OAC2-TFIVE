entity estagio_exe is
  port (
    -- Entrada
    clock : in std_logic;
    reset : in std_logic;
    RegWriteId : in std_logic; -- determina se o registrador de destino é escrito
    ResultSrcId : in std_logic; -- determina se o resultado da ALU é escrito
    MemWriteId : in std_logic; -- determina se a memória é escrita
    AluControl : in std_logic_vector(1 downto 0); -- determina a operação da ALU
    AluSrc : in std_logic; -- determina a origem do segundo operando da ALU
    Rd1 : in std_logic_vector(31 downto 0); -- primeiro operando da ALU
    Rd2 : in std_logic_vector(31 downto 0); -- segundo operando da ALU
    ImmExt : in std_logic_vector(31 downto 0); -- imediato extendido
    Rs1 : in std_logic_vector(31 downto 0); -- registrador de origem 1
    Rs2 : in std_logic_vector(31 downto 0); -- registrador de origem 2
    Rd : in std_logic_vector(31 downto 0); -- registrador de destino
    PcPlus4 : in std_logic_vector(31 downto 0); -- PC + 4
    -- Forward entradas
    RdM : in std_logic_vector(31 downto 0); -- registrador de destino do estágio MEM
    RdW : in std_logic_vector(31 downto 0); -- registrador de destino do estágio WB
    RegWriteM : in std_logic; -- determina se o registrador de destino do estágio MEM é escrito
    RegWriteW : in std_logic; -- determina se o registrador de destino do estágio WB é escrito
    -- Forward saídas
    FowardA : out std_logic_vector(1 downto 0); -- determina a origem do primeiro operando da ALU
    FowardB : out std_logic_vector(1 downto 0); -- determina a origem do segundo operando da ALU
    ForwardId : out std_logic_vector(1 downto 0); -- informa ao ID se há forwarding
    -- Saídas
    bem : out std_logic_vector(101 downto 0); -- barramento de entrada do estágio MEM
  );
end entity estagio_exe;




