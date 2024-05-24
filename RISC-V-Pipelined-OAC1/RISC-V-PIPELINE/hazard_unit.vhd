library ieee;
use ieee.std_logic_1164.all;

entity hazard_unit is
    port(
        reg_source_id1 : in std_logic_vector(4 downto 0);
        reg_source_id2 : in std_logic_vector(4 downto 0);
        reg_destin_ex  : in std_logic_vector(4 downto 0);
        result_src_ex  : in std_logic;
        pc_src_ex      : in std_logic;
        reg_source_ex1 : in std_logic_vector(4 downto 0);
        reg_source_ex2 : in std_logic_vector(4 downto 0);
        reg_destin_mm  : in std_logic_vector(4 downto 0);
        reg_destin_wb  : in std_logic_vector(4 downto 0);
        reg_write_mm   : in std_logic;
        reg_write_wb   : in std_logic;
        stall_if       : out std_logic;
        stall_id       : out std_logic;
        flush_id       : out std_logic;
        flush_ex       : out std_logic;
        alu_op1        : out std_logic_vector(1 downto 0);
        alu_op2        : out std_logic_vector(1 downto 0)
    );
end entity;

architecture hazard_unit_arch of hazard_unit is
    component hazard_detection_unit is
        port(
            reg_source_id1 : in std_logic_vector(4 downto 0);
            reg_source_id2 : in std_logic_vector(4 downto 0);
            reg_destin_ex  : in std_logic_vector(4 downto 0);
            result_src_ex  : in std_logic;
            pc_src_ex      : in std_logic;
            stall_if       : out std_logic;
            stall_id       : out std_logic;
            flush_id       : out std_logic;
            flush_ex       : out std_logic
        );
    end component hazard_detection_unit;

    component forwarding_unit is
        port(
        reg_source_ex1 : in std_logic_vector(4 downto 0);
        reg_source_ex2 : in std_logic_vector(4 downto 0);
        reg_destin_mm  : in std_logic_vector(4 downto 0);
        reg_destin_wb  : in std_logic_vector(4 downto 0);
        reg_write_mm   : in std_logic;
        reg_write_wb   : in std_logic;
        alu_op1, alu_op2  : out std_logic_vector(1 downto 0)
        );
    end component forwarding_unit;

    begin

        hazard: hazard_detection_unit
        port map(
            reg_source_id1 => reg_source_id1,
            reg_source_id2 => reg_source_id2,
            reg_destin_ex  => reg_destin_ex,
            result_src_ex  => result_src_ex,
            pc_src_ex      => pc_src_ex,
            stall_if       => stall_if,
            stall_id       => stall_id,
            flush_id       => flush_id,
            flush_ex       => flush_ex
        );

        forward: forwarding_unit
        port map(
            reg_source_ex1    => reg_source_ex1,
            reg_source_ex2    => reg_source_ex2,
            reg_destin_mm     => reg_destin_mm,
            reg_destin_wb     => reg_destin_wb,
            reg_write_mm      => reg_write_mm,
            reg_write_wb      => reg_write_wb,
            alu_op1           => alu_op1,
            alu_op2           => alu_op2
        );

end hazard_unit_arch;
