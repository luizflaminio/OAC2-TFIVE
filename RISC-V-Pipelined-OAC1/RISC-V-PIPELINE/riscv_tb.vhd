library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_bit.ALL;

entity testbench is
end;

architecture test of testbench is
	component top_level
		port(
			clock, reset: in STD_LOGIC;
			WriteData, DataAdr: out STD_LOGIC_VECTOR(31 downto 0);
	 		MemWrite: out STD_LOGIC;
			ReadEnable: out STD_LOGIC
		);
 	end component;

	signal WriteData_out, DataAdr_out   : STD_LOGIC_VECTOR(31 downto 0);
	signal clock_in, reset_in, MemWrite_out : STD_LOGIC := '0';
	signal ReadEnable_out: STD_LOGIC := '0'; 

	signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  	constant clockPeriod: time := 10 ns;

begin
	clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

	dut: top_level port map(clock_in, reset_in, WriteData_out, DataAdr_out, MemWrite_out, ReadEnable_out);

  stimulus: process is
	begin

	  assert false report "Inicio da simulacao" & LF & "... Simulacao ate 800 ms. Aguarde o final da simulacao..." severity note;
	  keep_simulating <= '1';

	  ---- inicio: reset ----------------
	  reset_in <= '1';
	  wait for 2*clockPeriod;
	  reset_in <= '0';
	  wait for 2*clockPeriod;

	  wait for 35*clockPeriod;

	  ---- final dos casos de teste  da simulacao
	  assert false report "Fim da simulacao" severity note;
	  keep_simulating <= '0';

	  wait; -- fim da simulação: aguarda indefinidamente
	end process;

	-- process(clock_in) begin
	-- 	if(clock_in'event and clock_in = '0' and MemWrite_out = '1') then
	-- 		if(to_integer(unsigned(to_bitvector(DataAdr_out))) = 100 and to_integer(unsigned(to_bitvector(writedata_out))) = 25) then
	-- 			report "NO ERRORS: Simulation succeeded" severity note;
	-- 		elsif (to_integer(unsigned(to_bitvector(DataAdr_out))) /= 96) then report "Simulation failed" severity failure;
	-- 		end if;
	-- 	end if;
	-- end process;
end;





