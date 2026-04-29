----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2025 05:31:46 PM
-- Design Name: 
-- Module Name: button_debounce_tb - Behavioral
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

entity button_debounce_tb is
end button_debounce_tb;

architecture Behavioral of button_debounce_tb is

    component button_debounce is
        Port(	clk: in  STD_LOGIC;
                reset : in  STD_LOGIC;
                button: in STD_LOGIC;
                action: out STD_LOGIC);
    end component button_debounce;
    
    signal w_clk : std_logic := '0';
    signal w_reset : std_logic := '0';
    signal w_button : std_logic := '0';
    signal w_action : std_logic := '0';
    
    constant clk_period : time := 10 ns;
    constant k_step : time := 20 ms;

begin

    button_debounce_inst : button_debounce
        Port Map(   clk => w_clk,
                    reset => w_reset,
                    button => w_button,
                    action => w_action
         );
         
    -- 100 MHz Clock generation process
    clk_process : process
    begin
        w_clk <= '0';
        wait for clk_period / 2;  -- 5 ns low
        w_clk <= '1';
        wait for clk_period / 2;  -- 5 ns high
    end process clk_process;
         
    test_process : process
    begin
        --button push
        w_button <= '0';
        wait for k_step;
        w_button <= '1';
        wait for k_step;
        w_button <= '0';
        
        
        wait;
    
    end process test_process;
        
        
    


end Behavioral;
