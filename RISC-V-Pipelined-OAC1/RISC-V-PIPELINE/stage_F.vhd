library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;

entity stage_f is
    port(
        clock       : in std_logic;
        reset       : in std_logic;
        pc_src_e    : in  std_logic;
        stall_f     : in  std_logic;
        target_addr : in  std_logic_vector(31 downto 0);
        pc_out      : out std_logic_vector(31 downto 0);
        pc_plus_4   : out std_logic_vector(31 downto 0)
    );
end entity stage_f;

architecture behav of stage_f is

    component d_register is
		generic (
			constant N: integer := 8
		);
		port (
			clock  : in  std_logic;
			reset  : in  std_logic;
			load   : in  std_logic;
			D      : in  std_logic_vector (N-1 downto 0);
			Q      : out std_logic_vector (N-1 downto 0)
		);
	end component;

    component adder is
	    port (
	        A, B      : in  STD_LOGIC_VECTOR(31 downto 0);
	        Sum       : out STD_LOGIC_VECTOR(31 downto 0)
	    );
    end component;

    component mux2 is
	    generic(
		    width: integer
	    );
	    port(
    		d0, d1 : in STD_LOGIC_VECTOR(width-1 downto 0);
 	    	s      : in STD_LOGIC;
     		y      : out STD_LOGIC_VECTOR(width-1 downto 0)
    	);
    end component;

    -- Int signals:
    signal s_pc_enable : std_logic;
    signal s_pc_out    : std_logic_vector(31 downto 0);
    signal s_next_pc   : std_logic_vector(31 downto 0);
    signal s_pc_plus_4 : std_logic_vector(31 downto 0);

begin

    pc_mux: mux2
        generic map (
            width => 32
        )
        port map (
            d0   => s_pc_plus_4,
            d1   => target_addr,
            s    => pc_src_e,
            y    => s_next_pc
        );


    s_pc_enable <= not stall_f;
    pc_reg: d_register
        generic map (
            N => 32
        )
        port map (
            clock  => clock,
			reset  => reset,
			load   => s_pc_enable,
			D      => s_next_pc,
			Q      => s_pc_out
        );

    pc_next_adder: adder
        port map (
            A =>  s_pc_out,
            B => X"00000004",
            Sum => s_pc_plus_4
        );

    -- Attribute int signals to interface signals:
    pc_out    <= s_pc_out;
    pc_plus_4 <= s_pc_plus_4;

end behav;
