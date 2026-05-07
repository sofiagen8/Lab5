--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;



architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
component TDM4 is
	generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
    Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	);
end component TDM4;

component clock_divider is
	generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
											   -- Effectively, you divide the clk double this 
											   -- number (e.g., k_DIV := 2 --> clock divider of 4)
	port ( 	i_clk    : in std_logic;
			i_reset  : in std_logic;		   -- asynchronous
			o_clk    : out std_logic		   -- divided (slow) clock
	);
end component clock_divider;

component twos_comp is
    port (
        i_bin: in std_logic_vector(7 downto 0);
        o_sign: out std_logic;
        o_hund: out std_logic_vector(3 downto 0);
        o_tens: out std_logic_vector(3 downto 0);
        o_ones: out std_logic_vector(3 downto 0)
    );
end component twos_comp;
  
component sevenseg_decoder is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
end component sevenseg_decoder;
  
component controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end component controller_fsm;
 
component ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0); --input from sw(2:0)
           o_result : out STD_LOGIC_VECTOR (7 downto 0); --send to MUX
           o_flags : out STD_LOGIC_VECTOR (3 downto 0)); --output on LED (15:12)
end component ALU;


--need to add signals here
    signal w_cycle : std_logic_vector(3 downto 0); --signal from controller fsm
    --signal w_A :  std_logic_vector(7 downto 0);
    --signal w_B:  std_logic_vector(7 downto 0);
    signal w_clk : std_logic; --signal from clock divider
    signal w_result : std_logic_vector(7 downto 0); --signal from ALU to MUX
    signal w_a :std_logic_vector(7 downto 0); --signal from register to ALU
    signal w_b : std_logic_vector(7 downto 0); --signal from register to ALU
  
begin
	-- PORT MAPS ----------------------------------------
    -- ALU_instance: ALU port map(
    --    i_A => w_a,
  --      i_B => w_b,
--        i_op(2) => sw(2),
      --  i_op(1) => sw(1),
    --    i_op(0) => sw(0),
  --      o_result => w_result, 
--        o_flags(3) => led(15),
      --  o_flags(2) => led(14),
    --    o_flags(1) => led(13),
  --      o_flags(0) => led(12)
--    );
controller_fsm_inst: controller_fsm port map(
           i_reset => btnU,
           i_adv  => btnC,
           o_cycle => w_cycle
           );
	
	--start by building out everything except ALU, 
	--get lights to work in order through clicking the button, then add ALU
	--the d-flip flops will be implemented as processes
	flip_proc : process (w_cycle) --no idea if this is going to work
    begin
        if (w_cycle = "0010") then
            w_a(0) <= sw(0); 
            w_a(1) <= sw(1); 
            w_a(2) <= sw(2); 
            w_a(3) <= sw(3); 
            w_a(4) <= sw(4); 
            w_a(5) <= sw(5); 
            w_a(6) <= sw(6); 
            w_a(7) <= sw(7); 
        elsif (w_cycle = "0100") then 
            w_b(0) <= sw(0); 
            w_b(1) <= sw(1); 
            w_b(2) <= sw(2); 
            w_b(3) <= sw(3); 
            w_b(4) <= sw(4); 
            w_b(5) <= sw(5); 
            w_b(6) <= sw(6); 
            w_b(7) <= sw(7); 
        end if;
    end process flip_proc;
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	
	
end top_basys3_arch;
