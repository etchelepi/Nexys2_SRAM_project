----------------------------------------------------------------------------------
-- Engineer: Evan Tchelepi
-- Create Date: 05/20/2013 10:09:59 PM
-- Module Name: BoardTest_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BoardTest_TB is
end BoardTest_TB;

architecture Behavioral of BoardTest_TB is

COMPONENT BoardTest is
    Port ( clk : in  STD_LOGIC;
           LEDS_OUT : out STD_LOGIC_VECTOR (7 downto 0);
    
        --PASS SIGNALS TO FPGA 
        LB : out STD_LOGIC; --Lowerbyte
        UB : out STD_LOGIC; --Upperbyte
    	CE : out STD_LOGIC; --Chip enable
        OE : out STD_LOGIC; --Out Enable Used for Read
        WE : out STD_LOGIC; --Write Enable Used for Write
    	ADDRESS : out STD_LOGIC_VECTOR(23 downto 1); --The 24 bit address line
    	DATA : inout STD_LOGIC_VECTOR(15 downto 0) --Data Bus Word mode
    			  );
end COMPONENT;

--Delcare inputs and init them--

signal clk : std_logic := '0';
signal LEDS_OUT : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
signal LB : std_logic;
signal UB : std_logic;
signal CE : std_logic;
signal OE : std_logic;
signal WE : std_logic;
signal ADDRESS : std_logic_vector(23 downto 1);
signal DATA : std_logic_vector(15 downto 0);

constant clk_period : time := 20 ns;

begin

uut:  BoardTest PORT MAP ( 
        clk => clk,
        LEDS_OUT => LEDS_OUT,

        LB => LB,
        UB => UB,
    	CE => CE,
        OE => OE,
        WE => WE,
    	ADDRESS => ADDRESS,
    	DATA => DATA
    			  );
			  
	  
clk_process : process
   begin
   clk <= '0';
   wait for clk_period/2;
  clk <= '1';
   wait for clk_period/2;
end process;


end Behavioral;
