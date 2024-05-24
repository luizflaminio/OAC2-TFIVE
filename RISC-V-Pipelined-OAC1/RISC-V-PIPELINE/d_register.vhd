
library ieee;
use ieee.std_logic_1164.all;

entity d_register is
    generic (
        constant N: integer := 8
    );
    port (
        clock  : in  std_logic;
        reset  : in  std_logic;
        load : in  std_logic;
        D      : in  std_logic_vector (N-1 downto 0);
        Q      : out std_logic_vector (N-1 downto 0)
    );
end entity d_register;

architecture comportamental of d_register is
    signal IQ: std_logic_vector(N-1 downto 0);
begin

process(clock, reset, load, IQ)
    begin
        if (clock'event and clock='1') then
            if (reset = '1') then IQ <= (others => '0');
            elsif (load='1') then IQ <= D;
            else IQ <= IQ;
            end if;
        end if;
        Q <= IQ;
    end process;

end architecture comportamental;
