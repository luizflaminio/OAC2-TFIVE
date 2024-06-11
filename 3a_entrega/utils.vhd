library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package utils is
    function to_hex_string(slv: std_logic_vector) return string;
end package utils;

package body utils is
    function to_hex_string(slv: std_logic_vector) return string is
        constant hex_chars: string := "0123456789ABCDEF";
        variable result: string(1 to slv'length / 4);
        variable nibble: integer;
    begin
        for i in 0 to slv'length / 4 - 1 loop
            nibble := to_integer(unsigned(slv(slv'left - (i * 4) downto slv'left - (i * 4) - 3)));
            result(result'length - i) := hex_chars(nibble + 1);
        end loop;
        return result;
    end function to_hex_string;
end package body utils;