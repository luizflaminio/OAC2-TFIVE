library ieee;
use ieee.std_logic_1164.all;

entity forwarding_unit is
    port(
        --Controle das entradas da ULA
        reg_source_ex1 : in std_logic_vector(4 downto 0); --Origem do dado 1
        reg_source_ex2 : in std_logic_vector(4 downto 0); --Origem do dado 2
        reg_destin_mm  : in std_logic_vector(4 downto 0); --Destino do dado (Memory)
        reg_destin_wb  : in std_logic_vector(4 downto 0); --Destino do dado (Write Back)
        reg_write_mm   : in std_logic; --Write enable (Memory)
        reg_write_wb   : in std_logic; --Write enable (Write Back)

        -- Mux selectors:
        alu_op1, alu_op2  : out std_logic_vector(1 downto 0)
    );
end entity forwarding_unit;

architecture forwarding_unit_arch of forwarding_unit is

begin

    alu_op1 <=  "00" when (reg_source_ex1 /= reg_destin_mm) and (reg_source_ex1 /= reg_destin_wb) else
                "01" when (reg_source_ex1 /= reg_destin_mm) and (reg_source_ex1 = reg_destin_wb) and reg_write_wb = '1' else
                "01" when (reg_source_ex1  = reg_destin_mm) and reg_write_mm = '0' and (reg_source_ex1 = reg_destin_wb) and reg_write_wb = '1' else
                "10" when (reg_source_ex1  = reg_destin_mm) and reg_write_mm = '1' else
                "00";

    alu_op2 <=  "00" when (reg_source_ex2 /= reg_destin_mm) and (reg_source_ex2 /= reg_destin_wb) else
                "01" when (reg_source_ex2 /= reg_destin_mm) and (reg_source_ex2 = reg_destin_wb) and reg_write_wb = '1' else
                "01" when (reg_source_ex2  = reg_destin_mm) and reg_write_mm = '0' and (reg_source_ex2 = reg_destin_wb) and reg_write_wb = '1' else
                "10" when (reg_source_ex2  = reg_destin_mm) and reg_write_mm = '1' else
                "00";

end forwarding_unit_arch ; -- forwarding_unit_arch
