library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.ALL;

entity testbench is
end;

architecture test of testbench is
	component top_level
		port(
			clk, reset: in STD_LOGIC;
			WriteData, DataAdr: out STD_LOGIC_VECTOR(31 downto 0);
	 		MemWrite: out STD_LOGIC
		);
 	end component;

	signal WriteData_out, DataAdr_out   : STD_LOGIC_VECTOR(31 downto 0);
	signal clk_in, reset_in, MemWrite_out : STD_LOGIC;

begin
 -- instantiate device to be tested
	dut: top_level port map(clk_in, reset_in, WriteData_out, DataAdr_out, MemWrite_out);
 -- Generate clock with 10 ns period
	process begin
	clk_in <= '1';
	wait for 5 ns;
	clk_in <= '0';
	wait for 5 ns;
end process;
-- Generate reset_in for first two clock cycles
process begin
	reset_in <= '1';
 	wait for 22 ns;
 	reset_in <= '0';
 	wait;
end process;
 -- check that 25 gets written to address 100 at end of program
process(clk_in) begin
	if(clk_in'event and clk_in = '0' and MemWrite_out = '1') then
 	if(to_integer(unsigned(to_bitvector(DataAdr_out)))) = 100 and to_integer(signed(to_bitvector(WriteData_out))) = 25 then
 	report "NO ERRORS: Simulation succeeded" severity
	failure;
 	elsif (to_integer(unsigned(to_bitvector(DataAdr_out))) /= 96) then
 	report "Simulation failed" severity failure;
 	end if;
 	end if;
 	end process;
end;
