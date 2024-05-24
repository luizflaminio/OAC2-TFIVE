library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity instruction_memory is
  generic(
    data_file_name : string  := "rom.txt" --! File with initial data
  );
  port(
    addr : in  std_logic_vector(31 downto 0);
    data : out std_logic_vector(31 downto 0)
  );
end instruction_memory;

architecture behavioural of instruction_memory is
  type mem_type is array (0 to 127) of std_logic_vector(7 downto 0); -- ROM file with 8 bits per line and we return 4 mem cells.
  impure function init_mem(file_name: in string) return mem_type is
    file f : text open read_mode is file_name;
    variable l : line;
    variable tmp_bv : bit_vector(7 downto 0);
    variable tmp_mem : mem_type;
  begin
    for i in mem_type'range loop
      readline(f, l);
      read(l, tmp_bv);
      tmp_mem(i) := To_StdLogicVector(tmp_bv);

    end loop;
    return tmp_mem;
  end;

  constant mem : mem_type := init_mem(data_file_name);
begin
  data <= mem(to_integer(unsigned(addr))) & mem(to_integer(unsigned(addr))+1) & mem(to_integer(unsigned(addr))+2) & mem(to_integer(unsigned(addr))+3);
end behavioural;
