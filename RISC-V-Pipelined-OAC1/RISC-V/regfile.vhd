library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;
use ieee.numeric_std.all;

entity regfile is
	generic(
		reg_n  : natural := 10;
		word_s : natural := 64
	);
	port(
		clock        : in  std_logic;
		reset        : in  std_logic;
		regWrite     : in  std_logic;
		rr1, rr2, wr : in  std_logic_vector (natural(ceil(log2(real(reg_n ))))-1 downto 0);
		d            : in  std_logic_vector (word_s-1 downto 0);
		q1, q2       : out std_logic_vector (word_s-1 downto 0)
	);
end regfile;

architecture regFile_arch of regfile is

	type reg_File is array (0 to reg_n-1) of std_logic_vector(word_s-1 downto 0);

	signal   reg_FileAT4 : reg_File;
	constant null_vector : std_logic_vector(word_s - 1 downto 0) := (others => '0');

begin

	reg_write: process (clock, reset) is
	begin
		if reset = '1' then
			Registradores: for I in 1 to reg_n-1 loop
				reg_FileAT4(I) <= null_vector;
			end loop;

		elsif rising_edge(clock) then
			if regWrite = '1' then
				if  to_integer(unsigned(wr)) > 0 then
					reg_FileAT4(to_integer(unsigned(wr))) <= d;
				end if;
			end if;
		end if;
	end process;

	q1 <= null_vector when to_integer(unsigned(rr1)) = 0 else
		  reg_FileAT4(to_integer(unsigned(rr1)));
	q2 <= null_vector when to_integer(unsigned(rr2)) = 0 else
		  reg_FileAT4(to_integer(unsigned(rr2)));

end architecture regFile_arch;
