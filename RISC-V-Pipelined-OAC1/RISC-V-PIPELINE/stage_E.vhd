library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;

entity stage_e is
    port(
        clock         : in  std_logic;
        reset         : in  std_logic;
        -- ID/EX regs inputs:
        data_reg_s1_e : in std_logic_vector(31 downto 0);
        data_reg_s2_e : in std_logic_vector(31 downto 0);
        pc_e          : in std_logic_vector(31 downto 0);
        imm_ext_e     : in std_logic_vector(31 downto 0);
        -- ID/EX control regs:
        alu_control_e : in std_logic_vector(2 downto 0);
        alu_src_e     : in std_logic;
        -- Inputs of forwarding mux
        alu_result_m  : in std_logic_vector(31 downto 0);
        result_w      : in std_logic_vector(31 downto 0);
        -- Forwarding unit:
        forwarding_a_e : in std_logic_vector(1 downto 0);
        forwarding_b_e : in std_logic_vector(1 downto 0);
        -- Outputs:
        alu_result_e   : out std_logic_vector(31 downto 0);
        write_data_e   : out  std_logic_vector(31 downto 0);
        pc_target_e    : out  std_logic_vector(31 downto 0);
        zero_e         : out std_logic

    );
end entity stage_e;

architecture behav of stage_e is

    component mux3 is
        generic(
            width: integer := 8
        );
        port(
            d0, d1, d2  : in std_logic_vector(width-1 downto 0);
             s 		    : in std_logic_vector(1 downto 0);
             y		    : out std_logic_vector(width-1 downto 0)
        );
    end component;

    component mux2 is
        generic(width: integer := 8);
        port(
            d0, d1 : in STD_LOGIC_VECTOR(width-1 downto 0);
            s      : in STD_LOGIC;
            y      : out STD_LOGIC_VECTOR(width-1 downto 0)
        );
    end component;

    component adder is
	    port (
	        A, B      : in  STD_LOGIC_VECTOR(31 downto 0);
	        Sum       : out STD_LOGIC_VECTOR(31 downto 0)
	    );
    end component;

    component alu is
        generic(
            size : natural := 4);
        port(
            A, B : in  std_logic_vector (size-1 downto 0);
            F    : out std_logic_vector (size-1 downto 0);
            S    : in  std_logic_vector (2 downto 0);
            Z    : out std_logic;
            Ov   : out std_logic;
            Co   : out std_logic
        );
    end component;


    -- Int signals:
    signal s_src_a_e, s_src_b_e  : std_logic_vector(31 downto 0);
    signal s_mux_b_forwarding_out    : std_logic_vector(31 downto 0);

begin

    forwarding_A_mux: mux3
        generic map (
            width => 32
        )
        port map (
            d0   => data_reg_s1_e,
            d1   => result_w,
            d2   => alu_result_m,
            s    => forwarding_a_e,
            y    => s_src_a_e
        );

    forwarding_B_mux: mux3
        generic map (
            width => 32
        )
        port map (
            d0   => data_reg_s2_e,
            d1   => result_w,
            d2   => alu_result_m,
            s    => forwarding_b_e,
            y    => s_mux_b_forwarding_out
        );

    alu_src_b_mux: mux2
        generic map (
            width => 32
        )
        port map (
            d0   => s_mux_b_forwarding_out,
            d1   => imm_ext_e,
            s    => alu_src_e,
            y    => s_src_b_e
        );


    alu_ex: alu
        generic map(
		size => 32
        )
	    port map (
		A    => s_src_a_e,
		B    => s_src_b_e,
        F    => alu_result_e,
		S    => alu_control_e,
		Z    => zero_e,
		Ov   => open,
		Co   => open
	);

    pc_target_adder: adder
        port map (
	        A    =>  pc_e,
	        B    => imm_ext_e,
            Sum  => pc_target_e
	    );

    -- Attribute int signals to interface signals:
    write_data_e  <= s_mux_b_forwarding_out;

end behav;
