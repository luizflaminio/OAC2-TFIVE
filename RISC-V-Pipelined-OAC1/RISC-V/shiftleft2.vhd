library ieee;
use ieee.numeric_bit.all;

entity shiftleft2 is
	generic (
		ws : natural := 64);
	port(
		i  : in  bit_vector (ws-1 downto 0);
		o  : out bit_vector (ws-1 downto 0)
	);
end entity shiftleft2;

architecture shiftleft2_arch of shiftleft2 is

begin
	o <=  i(ws-3 downto 0)&"00";
end architecture shiftleft2_arch;
