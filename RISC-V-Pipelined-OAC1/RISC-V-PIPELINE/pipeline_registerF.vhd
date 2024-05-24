library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;

entity pipe_regF is
    port (
        clk    : in std_logic;
        reset  : in std_logic;
        enable : in std_logic;
        PCF_in : in std_logic_vector(31 downto 0); --entrada da memoria de instruções
        PCPlus4F_in: in std_logic_vector(31 downto 0); --saida do somador PC + 4
        InstrF_in : in std_logic_vector(31 downto 0); --saida da memória de instruções
        PCD_out : out std_logic_vector(31 downto 0); --carrega ate execute
        PCPlus4D_out : out std_logic_vector(31 downto 0); --carrega ate write back
        InstrD_out : out std_logic_vector(31 downto 0) --carrega ate decode
    );
end entity pipe_regF;

architecture regF of pipe_regF is

    component d_register is
        generic(
            constant N: integer := 8
        );
        port(
            clock : in std_logic;
            reset : in std_logic;
            load  : in std_logic;
            d     : in std_logic_vector(N-1 downto 0);
            q     : out std_logic_vector(N-1 downto 0)
        );
    end component d_register;

begin

    PC: d_register generic map(N => 32) port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => PCF_in,
            q     => PCD_out
        );

    PCPlus4: d_register generic map(N => 32) port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => PCPlus4F_in,
            q     => PCPlus4D_out
        );

    Inst: d_register generic map(N => 32) port map(
            clock => clk,
            reset => reset,
            load  => enable,
            d     => InstrF_in,
            q     => InstrD_out
        );

end architecture regF;
