library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux3 is
	generic(
		width: integer := 8
	);
	port(
		d0, d1, d2 : in std_logic_vector(width-1 downto 0);
 		s 		   : in std_logic_vector(1 downto 0);
 		y		   : out std_logic_vector(width-1 downto 0) := (others => '0')
	);
end;

architecture behave of mux3 is
begin
	y <=  d0 when s = "00" else
		  d1 when s = "01" else
		  d2 when s = "10" else
		  (others => '0');
end;
