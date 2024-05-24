library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;

entity stage_d is
    port(
        clock           : in  std_logic;
        reset           : in std_logic;
        instruction     : in  std_logic_vector(31 downto 0);
        reg_write_w     : in  std_logic;
        addr_reg_write  : in  std_logic_vector(4 downto 0);
        data_reg_in     : in  std_logic_vector(31 downto 0);
        -- Interstage regs:
        data_reg_src1 : out std_logic_vector(31 downto 0);
        data_reg_src2 : out std_logic_vector(31 downto 0);
        imm_ext_d_out : out std_logic_vector(31 downto 0);
        -- Interstage control regs:
        reg_write_d   : out std_logic;
        result_src_d  : out std_logic_vector(1 downto 0);
        mem_write_d   : out std_logic;
        jump_d        : out std_logic;
        branch_d      : out std_logic;
        alu_control_d : out std_logic_vector(2 downto 0);
        alu_src_d     : out std_logic
    );
end entity stage_d;

architecture behav of stage_d is

    component extend is
        port(
            instruction  : in std_logic_vector(31 downto 7);
            imm_source  : in std_logic_vector(1 downto 0);
            imm_out     : out std_logic_vector(31 downto 0)
         );
    end component;

    component regfile is
        generic(
            reg_n  : natural := 10;
            word_s : natural := 64
        );
        port(
            clock        : in  std_logic;
            reset        : in  std_logic;
            regWrite     : in  std_logic;
            rr1, rr2, wr : in  std_logic_vector (natural(ceil(log2(real(reg_n ))))-1 downto 0);
            d            : in  std_logic_vector (word_s-1 downto 0);
            q1, q2       : out std_logic_vector (word_s-1 downto 0)
        );
    end component;

    component controller is
        port(
            op:             in STD_LOGIC_VECTOR(6 downto 0);
            funct3:         in STD_LOGIC_VECTOR(2 downto 0);
            funct7b5:       in STD_LOGIC;
            -- zero:        in std_logic;
            ResultSrc:      out STD_LOGIC_VECTOR(1 downto 0);
            MemWrite:       out STD_LOGIC;
            ALUSrc:         out STD_LOGIC;
            -- PCSrc:      out std_logic;
            RegWrite:       out STD_LOGIC;
            Branch:         out STD_LOGIC;
            Jump:           out STD_LOGIC; -- Change from buffer to out!
            ImmSrc:         out STD_LOGIC_VECTOR(1 downto 0);
            ALUControl:     out STD_LOGIC_VECTOR(2 downto 0));
    end component;

    -- Int signals:
    signal s_imm_src_d : std_logic_vector(1 downto 0);

begin

    imm_extend: extend
        port map (
            instruction  => instruction(31 downto 7),
            imm_source   => s_imm_src_d,
            imm_out      => imm_ext_d_out
        );

    control_unit: controller
        port map(
            op             =>  instruction(6 downto 0),
            funct3         =>  instruction(14 downto 12),
            funct7b5       =>  instruction(30),
            -- zero
            ResultSrc      =>  result_src_d,
            MemWrite       =>  mem_write_d,
            ALUSrc         =>  alu_src_d,
            -- PCSrc
            RegWrite       =>  reg_write_d,
            Branch         =>  branch_d,
            Jump           =>  jump_d,
            ImmSrc         =>  s_imm_src_d,
            ALUControl     =>  alu_control_d
        );


    register_file: regfile
        generic map (
            reg_n        => 32,
            word_s       => 32
        )
        port map(
            clock        => clock,
            reset        => reset,
            regWrite     => reg_write_w,
            rr1          => instruction(19 downto 15),
            rr2          => instruction(24 downto 20),
            wr           => addr_reg_write,
            d            => data_reg_in,
            q1           => data_reg_src1,
            q2           => data_reg_src2
        );

end behav;
