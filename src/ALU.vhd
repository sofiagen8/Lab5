----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is 

component ripple_adder is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           Cin : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (7 downto 0);
           Cout : out STD_LOGIC);
           
end component ripple_adder;
    
    signal w_add : std_logic_vector(7 downto 0);
    signal w_A : std_logic_vector(7 downto 0);
    signal w_B : std_logic_vector(7 downto 0);
    signal w_out : std_logic;
    signal w_result : std_logic_vector(7 downto 0);
    
begin

    w_A <= i_A;
    w_B <= i_B when (i_op(0) = '0') else
            NOT(i_B); --need to add 1 still?
            
    ripple_adder_inst: ripple_adder port map(
        A=> w_A,
        B=> w_B,
        Cin => i_op(0),
        S => w_add,
        Cout => w_out
    );
    
 
      w_result <= (w_add) when (i_op = "000") else
                    (w_add) when (i_op = "001") else --diagram puts B through a MUX, not even sure if current code works
                    (i_A and i_B) when (i_op = "010") else
                    (i_A or i_B) when (i_op = "100" ) else --changed from 011 for 1-hot
                    "00000000";
                    
      o_result <= w_result; --creation of signal helps with proper flag creation
                    
      --NZCV (keep in that order, 3-N, 2-Z, C-1, V-0
      
      --overflow (V-0) 
      o_flags(0) <= not((i_op(0) xor i_A(7) xor i_B(7))) and (i_A(7) xor w_add(7)) and (not(i_op(1))); 
      --carry (C-1)
      o_flags(1) <= w_out and not(i_op(1));
      --negative (3-N) --should take from ALU results
      o_flags(3) <= w_result(7); --7 is most significant bit
      --zero (Z-2) --should take from ALU results
      o_flags(2) <= (not(w_result(0)) and not(w_result(1)) and not(w_result(2)) and not(w_result(3)) and not(w_result(4)) and not(w_result(5)) and not(w_result(6)) and not(w_result(7)));
      --o_flags(1) <= NOT(w_add(0) or w_add(1) or w_add(2) or w_add(3) or w_add(4) or w_add(5) or w_add(6) or w_add(7));

end Behavioral;
