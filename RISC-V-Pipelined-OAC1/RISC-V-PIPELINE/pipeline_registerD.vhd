library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;

entity pipe_regD is
    port (
        clk    : in std_logic;
        reset  : in std_logic;
        enable : in std_logic; --sempre habilitado
        --sinais da UC
        RegWriteD_in : in std_logic;
        ResultSrcD_in : in std_logic_vector(1 downto 0);
        MemWriteD_in : in std_logic;
        JumpD_in : in std_logic;
        BranchD_in : in std_logic;
        ALUControlD_in : in std_logic_vector(2 downto 0);
        ALUSrcD_in : in std_logic;
        --sinais do FD
        RD1D_in : in std_logic_vector(31 downto 0);
        RD2D_in : in std_logic_vector(31 downto 0);
        PCD_in : in std_logic_vector(31 downto 0);
        Rs1D_in : in std_logic_vector(4 downto 0);
        Rs2D_in : in std_logic_vector(4 downto 0);
        RdD_in : in std_logic_vector(4 downto 0);
        ImmExtD_in : in std_logic_vector(31 downto 0);
        PCPlus4D_in: in std_logic_vector(31 downto 0);
        --saídas
        RegWriteE_out : out std_logic;
        ResultSrcE_out : out std_logic_vector(1 downto 0);
        MemWriteE_out : out std_logic;
        JumpE_out : out std_logic;
        BranchE_out : out std_logic;
        ALUControlE_out : out std_logic_vector(2 downto 0);
        ALUSrcE_out : out std_logic;
        RD1E_out : out std_logic_vector(31 downto 0);
        RD2E_out : out std_logic_vector(31 downto 0);
        PCE_out : out std_logic_vector(31 downto 0);
        Rs1E_out : out std_logic_vector(4 downto 0);
        Rs2E_out : out std_logic_vector(4 downto 0);
        RdE_out : out std_logic_vector(4 downto 0);
        ImmExtE_out : out std_logic_vector(31 downto 0);
        PCPlus4E_out: out std_logic_vector(31 downto 0)
    );
end entity pipe_regD;

architecture regD of pipe_regD is

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
        port(
            clock : in std_logic;
            reset : in std_logic;
            load  : in std_logic;
            d     : in std_logic;
            q     : out std_logic
        );
    end component reg_1bit;

begin

    RegWrite: reg_1bit
         port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => RegWriteD_in,
            q     => RegWriteE_out
        );

    ResultSrc: d_register
        generic map(
            N => 2
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => ResultSrcD_in,
            q     => ResultSrcE_out
        );

    MemWrite: reg_1bit
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => MemWriteD_in,
            q     => MemWriteE_out
        );

    Jump: reg_1bit
         port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => JumpD_in,
            q     => JumpE_out
        );

    Branch: reg_1bit
         port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => BranchD_in,
            q     => BranchE_out
        );

    ALUControl: d_register
        generic map(
            N =>3
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => ALUControlD_in,
            q     => ALUControlE_out
        );

    ALUSrc: reg_1bit
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => ALUSrcD_in,
            q     => ALUSrcE_out
        );

    RD1: d_register
        generic map(
            N => 32
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => RD1D_in,
            q     => RD1E_out
        );

    RD2: d_register
        generic map(
            N => 32
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => RD2D_in,
            q     => RD2E_out
        );

    PC: d_register
        generic map(
            N => 32
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => PCD_in,
            q     => PCE_out
        );

    Rs1: d_register
        generic map(
            N => 5
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => Rs1D_in,
            q     => Rs1E_out
        );

    Rs2: d_register
        generic map(
            N => 5
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => Rs2D_in,
            q     => Rs2E_out
        );

    Rd: d_register
        generic map(
                N => 5
            )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => RdD_in,
            q     => RdE_out
        );

    ImmExt: d_register
        generic map(
            N => 32
        )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => ImmExtD_in,
            q     => ImmExtE_out
        );

    PCPlus4: d_register
        generic map(
                N => 32
            )
        port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => PCPlus4D_in,
            q     => PCPlus4E_out
        );

end architecture regD;
