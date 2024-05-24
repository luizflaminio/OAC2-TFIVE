library ieee;
use ieee.numeric_bit.all;

entity d_register is
	generic(
		width : natural := 64
	);
	port(
		clock : in bit;
		reset : in bit;
		load  : in bit;
		d     : in bit_vector(width-1 downto 0);
		q     : out bit_vector(width-1 downto 0)
	);
end entity d_register;

architecture d_register_arch of d_register is

	signal q_auxiliar : bit_vector(width-1 downto 0);

	begin

		process( clock, reset ) begin
			if(reset = '1') then
				q_auxiliar <=  (others => '0');
			elsif(rising_edge(clock)) then
				if(load = '1') then
					q_auxiliar <= d;
				end if;
			end if;
		end process;

		q <= q_auxiliar;

end architecture d_register_arch;
