library ieee;
use IEEE.STD_LOGIC_1164.all;

entity alu is
	generic(
		size : natural := 4);
	port(
		A, B : in  std_logic_vector (size-1 downto 0);
		F    : out std_logic_vector (size-1 downto 0);
		S    : in  std_logic_vector (2 downto 0);
		Z    : out std_logic;
		Ov   : out std_logic;
		Co   : out std_logic
	);
end entity alu;

architecture arch_ula of alu is

	signal A_and_B    : std_logic_vector (size-1 downto 0) := (others => '0');
	signal A_or_B     : std_logic_vector (size-1 downto 0) := (others => '0');
	signal A_Add_B    : std_logic_vector (size-1 downto 0) := (others => '0');
	signal A_SLT_B    : std_logic_vector (size-1 downto 0) := (others => '0');
	signal A_ready    : std_logic_vector (size-1 downto 0) := (others => '0');
	signal B_ready    : std_logic_vector (size-1 downto 0) := (others => '0');
	signal Carry      : std_logic_vector (size downto 0);
	signal Ov_copy    : std_logic;
	signal nullVector : std_logic_vector (size-1 downto 0) := (others => '0');
	signal zeroADD    : std_logic_vector (size downto 0)   := (others => '0');
	signal zeroAND    : std_logic_vector (size downto 0)   := (others => '0');
	signal zeroOR     : std_logic_vector (size downto 0)   := (others => '0');
	signal op_sub     : std_logic;

begin
-- Valores de A, B e carry usados no FullAdder e portas lógicas.
	op_sub <= (not S(1)) and S(0);
	Carry(0) <=  op_sub;

	A_ready <= A;

	with op_sub select
	B_ready <= B   when '0',
			not(B) when '1',
			nullVector when others;

	with S select
	F <=   A_Add_B  when "000" | "001",
		   A_and_B  when "010",
		   A_or_B   when "011",
		   A_SLT_B  when "101",
		   (others => '0') when others;

	ADDITION : for I in size-1 downto 0 generate
		A_Add_B(I) <= A_ready(I) xor B_ready(I) xor Carry(I);
		Carry(I+1) <= (B_ready(I) and Carry(I)) or (Carry(I) and A_ready(I)) or (A_ready(I) and B_ready(I));
	end generate;

	AND_BITaBIT : for I in size-1 downto 0 generate
		A_and_B(I) <= A_ready(I) and B_ready(I);
	end generate;

	OR_BITaBIT : for I in size-1 downto 0 generate
		A_or_B(I) <= A(I) or B(I);
	end generate;

	A_SLT_B(size-1 downto 1) <= nullVector(size-1 downto 1);

	with Ov_copy select
	A_SLT_B(0) <= A_ready(size-1) and B_ready(size-1)  when '1',
				  A_Add_B(size-1)              when others;

	with S select
	Z <= not(zeroAND(size)) when "010",
		 not(zeroOR(size))  when "011",
		 not(zeroADD(size)) when "000",
		 not(zeroADD(size)) when "001",
		 not(A_SLT_B(0))    when "101",
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

	Ov_copy <= ( (not A_ready(size-1)) and (not B_ready(size-1)) and  A_Add_B(size-1)       ) or ( A_ready(size-1)  and B_ready(size-1) and (not A_Add_B(size-1))     );
	Ov <= Ov_copy;

	Co <= Carry(size);
end architecture;
