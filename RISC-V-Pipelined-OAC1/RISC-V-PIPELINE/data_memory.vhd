library ieee;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_bit.ALL;

entity data_memory is
  port(
    clock, write_enable  : in  std_logic;
    read_enable          : in  std_logic;
    addr                 : in  std_logic_vector(31 downto 0);
    data_in              : in  std_logic_vector(31 downto 0);
    data_out             : out std_logic_vector(31 downto 0)
  );
end data_memory;

architecture behavioral of data_memory is
  type mem_type is array (0 to 1023) of std_logic_vector(7 downto 0);
  signal mem : mem_type;
  signal address : natural;
begin
  wrt: process(clock)
  begin
    if (clock='1' and clock'event) then
      if (write_enable='1') then
        mem(to_integer(unsigned(to_bitvector(addr))))   <= data_in(31 downto 24);
        mem(to_integer(unsigned(to_bitvector(addr)))+1) <= data_in(23 downto 16);
        mem(to_integer(unsigned(to_bitvector(addr)))+2) <= data_in(15 downto 8);
        mem(to_integer(unsigned(to_bitvector(addr)))+3) <= data_in(7 downto 0);
      end if;
    end if;
  end process;
  with read_enable select
    address <= to_integer(unsigned(to_bitvector(addr))) when '1',
               0 when others;
    data_out <= mem(address) & mem(address+1) & mem(address+2) & mem(address+3);
end behavioral;
