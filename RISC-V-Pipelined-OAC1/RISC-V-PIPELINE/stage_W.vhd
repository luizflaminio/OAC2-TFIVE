library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.math_real.all;

entity stage_w is
    port(
        clock            : in std_logic;
        reset            : in std_logic;
        -- MEM/WB regs
        read_data_w      : in  std_logic_vector(31 downto 0);
        pc_plus_4_w      : in std_logic_vector(31 downto 0);
        alu_result_m_out : in std_logic_vector(31 downto 0);
        -- MEM/WB control
        result_src_w     : in std_logic_vector(1 downto 0);
        -- Output
        result_w         : out std_logic_vector(31 downto 0)
    );
end entity stage_w;

architecture behav of stage_w is

    component mux3 is
	    generic(
		    width: integer
	    );
	    port(
    		d0, d1, d2 : in STD_LOGIC_VECTOR(width-1 downto 0);
 	    	s          : in STD_LOGIC_VECTOR(1 downto 0);
     		y          : out STD_LOGIC_VECTOR(width-1 downto 0)
    	);
    end component;

begin

    result_mux: mux3
        generic map (
            width => 32
        )
        port map (
            d0   => alu_result_m_out,
            d1   => read_data_w,
            d2   => pc_plus_4_w,
            s    => result_src_w,
            y    => result_w
        );

end behav;
