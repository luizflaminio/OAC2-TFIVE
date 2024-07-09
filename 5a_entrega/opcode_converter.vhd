library ieee;
use ieee.std_logic_1164.all;

library work;
use work.tipos.all;

package opcode_converter is
  function decode(instruction: std_logic_vector(31 downto 0)) return instruction_type;
end package opcode_converter;

package body opcode_converter is
  function decode(instruction: std_logic_vector(31 downto 0)) return instruction_type is
    variable opcode: std_logic_vector(6 downto 0);
    variable funct3: std_logic_vector(2 downto 0);
    variable funct7: std_logic_vector(6 downto 0);
    begin
      opcode := instruction(6 downto 0);
      funct3 := instruction(14 downto 12);
      funct7 := instruction(31 downto 25);

      if opcode = "0110011" then -- R-type
        case funct3 is 
          when "000" => return ADD;
          when "010" => return SLT;
          when others => return NOINST;
        end case;
      end if;

      if opcode = "0010011" then -- I-type
        case funct3 is 
          when "000" => return ADDI;
          when "010" => return SLTI;
          when "001" => return SLLI;
          when "101" => 
            if funct7 = "0000000" then
              return SRLI;
            elsif funct7 = "0100000" then
              return SRAI;
            else
              return NOINST;
            end if;
          when others =>return NOINST;
        end case;

      elsif opcode = "0000011" then 
          return LW;

      elsif opcode = "0100011" then 
          return SW;

      elsif opcode = "1100011" then
        case funct3 is
          when "000" => return BEQ;
          when "001" => return BNE;
          when "100" => return BLT;
          when others => return NOINST;
        end case;

      elsif opcode = "1101111" then
        if instruction(31 downto 7) = "0000000000000000000000000" then
          return HALT;
        else
          return JAL;
        end if;

      elsif opcode = "1100111" then
        return JALR;

      elsif opcode = "0000000" then
        return NOP;
        
      else
        return NOINST;
      end if;
    end decode;
end package body opcode_converter;