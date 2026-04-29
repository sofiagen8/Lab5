----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is
    type sm_state is (s_0, s_1, s_2, s_3);
	
	signal f_Q, f_Q_next: sm_state;

begin

	-- CONCURRENT STATEMENTS ------------------------------------------------------------------------------
	
	-- Next State Logic
    f_Q_next <= s_0 when (f_Q = s_3 and i_adv = '1') else -- going up
            s_0 when (i_reset = '1') else
            s_1 when (f_Q = s_0 and i_adv = '1') else
            s_2 when (f_Q = s_1 and i_adv = '1') else --when top floor and it will stay there while 1
            s_3 when (f_Q = s_2 and i_adv = '0') else -- going down
            s_0; -- default case 
            
	-- Output logic
    with f_Q select
    o_cycle <= "0001" when s_0,
            "0010" when s_1,
            "0011" when s_2,
            "0100" when s_3,
            "0001" when others; -- default is s_0

	-------------------------------------------------------------------------------------------------------
	
	-- PROCESSES ------------------------------------------------------------------------------------------	
	--IF SOMETHING NOT WORKING CORRECTLY, THEN REGISTER HERE IS AT FAULT FOR FSM
	-- State register ------------
	register_proc : process (i_adv, i_reset)
    begin
        if i_reset = '1' then
            f_Q <= s_0; 
        elsif (rising_edge(i_adv)) then
            f_Q <= f_Q_next; --next state becomes current state
        end if;
    end process register_proc;

end FSM;
