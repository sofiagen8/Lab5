--------------------------------------------------------------------
-- Name:	George York
-- Date:	Feb 2, 2021
-- File:	button_debounce.vhdl
-- HW:	    Lecture 10
--	Crs:	ECE 383
--
-- Purp:	For this debouncer, we assume the clock is slowed from 100MHz to 100KHz,
--          and the ringing time is less than 20ms
--
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
------------------------------------------------------------------------- 
library IEEE;		
use IEEE.std_logic_1164.all; 
use IEEE.NUMERIC_STD.ALL;

entity button_debounce is
	Port(	clk: in  STD_LOGIC;
			reset : in  STD_LOGIC;
			button: in STD_LOGIC;
			action: out STD_LOGIC);
end button_debounce;

architecture behavior of button_debounce is
	
	signal cw: STD_LOGIC_VECTOR(1 downto 0):= (others => '0');
	signal less: STD_LOGIC:= '0';
	type state_type is (Action0, Comp1, Init2, Comp2, Inc2, Comp3, Init4, Comp4, Inc4, Action1);
	signal state: state_type;
	
	COMPONENT counter    -- clock for 20 msec debounce delay
		generic (N: integer := 4);
		Port(	clk: in  STD_LOGIC;
				reset : in  STD_LOGIC;
				crtl: in std_logic_vector(1 downto 0);
				D: in unsigned (N-1 downto 0);
				Q: out unsigned (N-1 downto 0));
    END COMPONENT;
	
	-- these values are for 100MHz
    signal D : unsigned(20 downto 0) := (others => '0');
    signal Q : unsigned(20 downto 0);
    
	-- these values are for 100KHz
    --signal D : unsigned(10 downto 0) := (others => '0');
    --signal Q : unsigned(10 downto 0);
        
begin
   ------  DATAPATH ---------------------
	delay_counter: counter 
	Generic map(21)
    --Generic map(11)
	PORT MAP (
          clk => clk,
          reset => reset,
		  crtl => cw,
          D => D,
          Q => Q
        );	
	
	-- reminder: counter counter every other clock cycle!
    -- these values are for 100MHz clock
    less <= '1' when (Q < "111101000010010000000") else '0';
   	-- these values are for 100KHz clock
    --less <= '1' when (Q < 1000) else '0';
    
	
   ----------  CONTROL PATH --------------------------------	
   state_process: process(clk)
	 begin
		if (rising_edge(clk)) then
			if (reset = '1') then 
				state <= Action0;
			else
				case state is
					when Action0 =>
						state <= Comp1;
					when Comp1 =>
						if (button = '1') then state <= Init2; end if;
					when Init2 =>
						state <= Comp2;	
					when Comp2 =>
						if (less = '1') then state <= Inc2; else state <= Comp3; end if;
					when Inc2 =>
						state <= Comp2;					
					when Comp3 =>
						if (button = '0') then state <= Init4; end if;
					when Init4 =>
						state <= Comp4;	
					when Comp4 =>
						if (less = '1') then state <= Inc4; else state <= Action1; end if;
                    when Inc4 =>
						state <= Comp4;	
					when Action1 =>
                        state <= Action0;    					
				end case;
			end if;
		end if;
	end process;


	------------------------------------------------------------------------------
	--			OUTPUT EQUATIONS
	--	
	--		cw is counter control:  00 is hold; 01 is increment; 11 is reset	
	------------------------------------------------------------------------------	
	cw <=   "00" when state = Action0 else
			"00" when state = Comp1 else
			"11" when state = Init2 else 
			"00" when state = Comp2 else
			"01" when state = Inc2 else
			"00" when state = Comp3 else
			"11" when state = Init4 else 
			"00" when state = Comp4 else
			"01" when state = Inc4 else
			"00"; -- when state = Action1;
				
	action <= '1' when state = Action1 else '0';
	
	
	
end behavior;