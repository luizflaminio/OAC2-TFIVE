library ieee;
use ieee.std_logic_1164.all;

entity bit_adder is
  port (
		A, B, Ci : in std_logic;
		S, Co    : out std_logic
	);
end bit_adder;

architecture behavior of bit_adder is
begin
 s <= A xor B xor ci;

 co <= (A and B) or ((a xor b) and Ci);
end behavior;
