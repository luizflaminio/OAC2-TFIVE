-- Sign extend:
-- receives part of the instruction
-- receives a selector from the controller.
-- returns 32 bits extended immediate

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity extend is
	port(
		instruction : in std_logic_vector(31 downto 7);
	 	imm_source  : in std_logic_vector(1 downto 0);
	 	imm_out		: out std_logic_vector(31 downto 0)
 	);
end;

architecture behavioral of extend is
begin
	process(instruction, imm_source) begin
		case imm_source is
			-- I-type
			when "00" =>
				imm_out <= (31 downto 12 => instruction(31)) & instruction(31 downto 20);
			-- S-types (stores)
			when "01" =>
				imm_out <= (31 downto 12 => instruction(31)) & instruction(31 downto 25) & instruction(11 downto 7);
			-- B-type (branches)
			when "10" =>
				imm_out <= (31 downto 12 => instruction(31)) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';
			-- J-type (jal) Talvez nao usemos.
			when "11" =>
				imm_out <= (31 downto 20 => instruction(31)) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0';
			when others =>
				imm_out <= (31 downto 0 => '0');
		end case;
	end process;
end behavioral;
