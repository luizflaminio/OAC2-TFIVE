library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;


entity pipe_regM is
    port (
        clk    : in std_logic;
        reset  : in std_logic;
        enable : in std_logic; --smpre habilitado
        --sinais da UC
        RegWriteM_in : in std_logic;
        ResultSrcM_in : in std_logic_vector(1 downto 0);
        --sinais do FD
        ALUResultM_in : in std_logic_vector(31 downto 0);
        ReadDataM_in : in std_logic_vector(31 downto 0);
        RdM_in : in std_logic_vector(4 downto 0);
        PCPlus4M_in : in std_logic_vector(31 downto 0);
        --saídas
        RegWriteW_out : out std_logic;
        ResultSrcW_out : out std_logic_vector(1 downto 0);
        ALUResultW_out : out std_logic_vector(31 downto 0);
        ReadDataW_out : out std_logic_vector(31 downto 0);
        RdW_out : out std_logic_vector(4 downto 0);
        PCPlus4W_out : out std_logic_vector(31 downto 0)
    );
end entity pipe_regM;

architecture regM of pipe_regM is

    component d_register is
        generic(
            N : natural := 64
        );
        port(
            clock : in std_logic;
            reset : in std_logic;
            load  : in std_logic;
            d     : in std_logic_vector(N-1 downto 0);
            q     : out std_logic_vector(N-1 downto 0)
        );
    end component d_register;

    component reg_1bit is
        port (
            clock  : in  std_logic;
            reset  : in  std_logic;
            load   : in  std_logic;
            D      : in  std_logic;
            Q      : out std_logic
        );
    end component reg_1bit;

begin

    RegWrite: reg_1bit
         port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => RegWriteM_in,
            q     => RegWriteW_out
        );

    ResultSrc: d_register
        generic map(
            N => 2
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => ResultSrcM_in,
            q     => ResultSrcW_out
        );

    ALUResult: d_register
        generic map(
            N => 32
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => ALUResultM_in,
            q     => ALUResultW_out
        );

    ReadData: d_register
        generic map(
            N =>32
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => ReadDataM_in,
            q     => ReadDataW_out
        );

    Rd: d_register
        generic map(
            N => 5
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => RdM_in,
            q     => RdW_out
        );

    PCPlus4: d_register
        generic map(
            N => 32
        )
        port map (
            clock => clk,
            reset => reset,
            load  => enable,
            d     => PCPlus4M_in,
            q     => PCPlus4W_out
        );

end architecture regM;
