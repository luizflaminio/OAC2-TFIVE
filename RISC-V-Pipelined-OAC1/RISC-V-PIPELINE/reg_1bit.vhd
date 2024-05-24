
library ieee;
use ieee.std_logic_1164.all;

entity reg_1bit is
    port (
        clock  : in  std_logic;
        reset  : in  std_logic;
        load   : in  std_logic;
        D      : in  std_logic;
        Q      : out std_logic
    );
end entity reg_1bit;

architecture comportamental of reg_1bit is
    signal IQ: std_logic;
begin

process(clock, reset, load, IQ)
    begin
        if (clock'event and clock='1') then
            if (reset = '1') then IQ <= '0';
            elsif (load='1') then IQ <= D;
            else IQ <= IQ;
            end if;
        end if;
        Q <= IQ;
    end process;

end architecture comportamental;
