library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity pipe_regE is
    port (
        clk    : in std_logic;
        reset  : in std_logic;
        enable : in std_logic; --smpre habilitado
        --sinais da UC
        RegWriteE_in : in std_logic;
        ResultSrcE_in : in std_logic_vector(1 downto 0);
        MemWriteE_in : in std_logic;
        --sinais do FD
        ALUResultE_in : in std_logic_vector(31 downto 0);
        WriteDataE_in : in std_logic_vector(31 downto 0);
        RdE_in : in std_logic_vector(4 downto 0);
        PCPlus4E_in: in std_logic_vector(31 downto 0);
        --saídas
        RegWriteM_out : out std_logic;
        ResultSrcM_out : out std_logic_vector(1 downto 0);
        MemWriteM_out : out std_logic;
        ALUResultM_out : out std_logic_vector(31 downto 0);
        WriteDataM_out : out std_logic_vector(31 downto 0);
        RdM_out : out std_logic_vector(4 downto 0);
        PCPlus4M_out: out std_logic_vector(31 downto 0)
    );
end entity pipe_regE;

architecture regE of pipe_regE is

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
            d     => RegWriteE_in,
            q     => RegWriteM_out
        );

    ResultSrc: d_register
        generic map(
            N => 2
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => ResultSrcE_in,
            q     => ResultSrcM_out
        );

    MemWrite: reg_1bit
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => MemWriteE_in,
            q     => MemWriteM_out
        );

    ALUResult: d_register
        generic map(
            N => 32
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => ALUResultE_in,
            q     => ALUResultM_out
        );

    WriteData: d_register
        generic map(
            N => 32
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => WriteDataE_in,
            q     => WriteDataM_out
        );

    Rd: d_register
        generic map(
            N =>5
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => RdE_in,
            q     => RdM_out
        );

    PCPlus4: d_register
        generic map(
            N => 32
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => PCPlus4E_in,
            q     => PCPlus4M_out
        );

end architecture regE;
