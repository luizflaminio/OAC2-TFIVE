library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity adder is
  port (
    A, B      : in  STD_LOGIC_VECTOR(31 downto 0);
    Sum       : out STD_LOGIC_VECTOR(31 downto 0)
  );
end adder;

architecture behavior of adder is
  component bit_adder is
    port (
      A, B, Ci : in std_logic;
      S, Co: out std_logic
    );
  end component;

  signal carry : STD_LOGIC_VECTOR(32 downto 0);
  signal sum_internal : STD_LOGIC_VECTOR(31 downto 0);
begin
  -- Instantiate 1-bit adders in a loop
  adder_i: for i in 0 to 31 generate
    adder_inst : bit_adder
      port map (
        A => A(i),
        B => B(i),
        Ci => carry(i),
        S => sum_internal(i),
        Co => carry(i+1)
      );
  end generate;

  -- Connect input and output signals
  carry(0) <= '0';
  Sum <= sum_internal;
end behavior;

