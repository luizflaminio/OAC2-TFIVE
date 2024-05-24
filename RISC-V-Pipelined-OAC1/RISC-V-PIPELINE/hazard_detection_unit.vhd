library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection_unit is
    port(
        reg_source_id1 : in std_logic_vector(4 downto 0); --Origem do dado 1
        reg_source_id2 : in std_logic_vector(4 downto 0); --Origem do dado 2
        reg_destin_ex  : in std_logic_vector(4 downto 0); --Destino do dado
        result_src_ex  : in std_logic;  --Indica se o dado foi lido da memória
        pc_src_ex      : in std_logic;  --Indica se houve branch
        stall_if       : out std_logic; --Enable do registrador PC
        stall_id       : out std_logic; --Enable do registrador ID
        flush_id       : out std_logic; --Clear do registrador ID
        flush_ex       : out std_logic  --Clear do registrador EX
    );
end entity hazard_detection_unit;

architecture hazard_detection_unit_arch of hazard_detection_unit is

    signal bubble_s : std_logic;

begin

    bubble_s <= '1' when result_src_ex = '1' and ((reg_source_id1 = reg_destin_ex) or (reg_source_id2 = reg_destin_ex)) else
              '0';

    stall_if <= bubble_s;
    stall_id <= bubble_s;
    flush_ex <= bubble_s or pc_src_ex;
    flush_id <= pc_src_ex;

end hazard_detection_unit_arch ; -- hazard_detection_unit_arch
