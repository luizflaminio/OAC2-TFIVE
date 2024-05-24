library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity data_memory is
  port(
    clock, write_enable  : in  std_logic;
    addr                 : in  std_logic_vector(31 downto 0);
    data_in              : in  std_logic_vector(31 downto 0);
    data_out             : out std_logic_vector(31 downto 0)
  );
end data_memory;

architecture behavioral of data_memory is
  type mem_type is array (0 to 1023) of std_logic_vector(31 downto 0);
  signal mem : mem_type := (others => (others => '0'));

begin
  wrt: process(clock)
  begin
    if (clock='1' and clock'event) then
      if (write_enable='1') then
        mem(to_integer(unsigned(addr(9 downto 0)))) <= data_in;
      end if;
    end if;
  end process;

  data_out <= mem(to_integer(unsigned(addr(9 downto 0))));

end behavioral;
