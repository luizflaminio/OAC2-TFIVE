library ieee;
use ieee.numeric_bit.all;

entity alu is
	generic(
		size : natural := 4);
	port(
		A, B : in  bit_vector (size-1 downto 0);
		F    : out bit_vector (size-1 downto 0);
		S    : in  bit_vector (3 downto 0);
		Z    : out bit;
		Ov   : out bit;
		Co   : out bit
	);
end entity alu;

architecture arch_ula of alu is

	signal A_and_B    : bit_vector (size-1 downto 0);
	signal A_or_B     : bit_vector (size-1 downto 0);
	signal A_Add_B    : bit_vector (size-1 downto 0);
	signal A_SLT_B    : bit_vector (size-1 downto 0);
	signal A_ready    : bit_vector (size-1 downto 0);
	signal B_ready    : bit_vector (size-1 downto 0);
	signal Carry      : bit_vector (size downto 0);
	signal Ov_copy    : bit;
	signal nullVector : bit_vector (size-1 downto 0) := (others => '0');
	signal zeroADD    : bit_vector (size downto 0)   := (others => '0');
	signal zeroAND    : bit_vector (size downto 0)   := (others => '0');
	signal zeroOR     : bit_vector (size downto 0)   := (others => '0');

begin
-- Valores de A, B e carry usados no FullAdder e portas lógicas.
	Carry(0) <= S(2);

	with S(3) select
	A_ready <= A   when '0',
			not(A) when '1',
			nullVector when others;

	with S(2) select
	B_ready <= B   when '0',
			not(B) when '1',
			nullVector when others;

	-- Gerar resultado:
	F <=   A_Add_B  when S = "0010" or S = "0110" else
		   A_and_B   when S = "0000" or S = "1100" else
		   A_or_B    when S = "0001" 			   else
		   A_SLT_B   when S = "0111";

	-- Primeira operação:
	AND_BITaBIT : for I in size-1 downto 0 generate
		A_and_B(I) <= A_ready(I) and B_ready(I);
	end generate;

		-- Segunda operação:
	OR_BITaBIT : for I in size-1 downto 0 generate
		A_or_B(I) <= A(I) or B(I);
	end generate;

	-- Terceira operação:
	ADDITION : for I in size-1 downto 0 generate
		A_Add_B(I) <= A_ready(I) xor B_ready(I) xor Carry(I);
		Carry(I+1) <= (B_ready(I) and Carry(I)) or (Carry(I) and A_ready(I)) or (A_ready(I) and B_ready(I));
	end generate;

	-- Quinta operação:
	A_SLT_B(size-1 downto 1) <= nullVector(size-1 downto 1);

	with Ov_copy select
	A_SLT_B(0) <= A_ready(size-1) and B_ready(size-1)  when '1',
				  A_Add_B(size-1)              when others;

	-- Zero flag:
	with S select
	Z <= not(zeroAND(size)) when "0000",
		 not(zeroOR(size))  when "0001",
		 not(zeroADD(size)) when "0010",
		 not(zeroADD(size)) when "0110",
		 not(A_SLT_B(0))    when "0111",
		 not(zeroAND(size)) when "1100",
			       	'0'	   when others;

	Zero_1: for I in size-1 downto 0 generate
		zeroAND(I+1) <= zeroAND(I) or (A_and_B(I));
	end generate;

	Zero_2: for I in size-1 downto 0 generate
		zeroOR(I+1) <= zeroOR(I) or (A_or_B(I));
	end generate;

	Zero_3: for I in size-1 downto 0 generate
		zeroADD(I+1) <= zeroADD(I) or (A_Add_B(I));
	end generate;

	-- Overflow:
	Ov_copy <= ( (not A_ready(size-1)) and (not B_ready(size-1)) and  A_Add_B(size-1)       ) or ( A_ready(size-1)  and B_ready(size-1) and (not A_Add_B(size-1))     );
	Ov <= Ov_copy;
	-- Carry:
	Co <= Carry(size);
end architecture;
