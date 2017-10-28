----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/03/2013 11:50:34 PM
-- Design Name: 
-- Module Name: CTRL_BOARD_TEST_TB - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CTRL_BOARD_TEST_TB is
end CTRL_BOARD_TEST_TB;



architecture Behavioral of CTRL_BOARD_TEST_TB is

--END FILE IO--

COMPONENT CTRL_BOARD_TEST is
    Port ( clk_in : in  STD_LOGIC;
			  --Switch DATA
			  DATA_SWITCH_8_BIT : in STD_LOGIC_VECTOR (7 downto 0);
			  WRITE_BUTTON : in STD_LOGIC;
			  READ_BUTTON : in STD_LOGIC;
			  RESET_BUTTON : in STD_LOGIC;
			  LEDS_OUT : out STD_LOGIC_VECTOR (7 downto 0);
			  
			  LA_ADDRESS : out STD_LOGIC_VECTOR(23 downto 1);
              LA_CLK : out STD_LOGIC;
			  DEBUG_SIG_CE : out STD_LOGIC;
			  DEBUG_SIG_OE : out STD_LOGIC;
			  DEBUG_SIG_WE : out STD_LOGIC;
			  
			  GARBAGE : out STD_LOGIC_VECTOR (15 downto 0);
			  --Pass-Through_signals--
			  ADV : out STD_LOGIC; -- Needs to be low
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

signal clk : std_logic;--:= '0';
signal DATA_SWITCH_8_BIT_d  : std_logic_vector(7 downto 0) := "10101010";
signal WRITE_BUTTON_d : std_logic := '0';
signal READ_BUTTON_d : std_logic := '0';
signal LEDS_OUT_d : std_logic_vector (7 downto 0):= "00000000";
signal DEBUG_SIG_CE_d : std_logic := '0';
signal DEBUG_SIG_OE_d : std_logic := '0';
signal DEBUG_SIG_WE_d : std_logic := '0';
Signal Sensor_Enable_d  : std_logic := '0';
signal RESET_BUTTON_d : std_logic := '1';


signal GARBAGE : STD_LOGIC_VECTOR (15 downto 0);

--Declare outputs
signal ADV : std_logic;
signal LB : std_logic;
signal UB : std_logic;
signal CE : std_logic;
signal OE : std_logic;
signal WE : std_logic;
signal ADDRESS : std_logic_vector(23 downto 1);
signal LA_ADDRESS : std_logic_vector (23 downto 1);
signal DATA : std_logic_vector(15 downto 0);

constant clk_period : time := 20 ns;



begin


uut: CTRL_BOARD_TEST PORT MAP ( 
              clk_in => clk,
              DATA_SWITCH_8_BIT => DATA_SWITCH_8_BIT_d,
              WRITE_BUTTON => WRITE_BUTTON_d,
			  READ_BUTTON => READ_BUTTON_d,
			  RESET_BUTTON => RESET_BUTTON_d,
			  LEDS_OUT => LEDS_OUT_d,
			  
			  LA_ADDRESS => LA_ADDRESS,
			  LA_CLK => open,
			  DEBUG_SIG_CE => DEBUG_SIG_CE_d,
			  DEBUG_SIG_OE => DEBUG_SIG_OE_d,
			  DEBUG_SIG_WE => DEBUG_SIG_WE_d,
			  
			  GARBAGE => GARBAGE,
			 
			  --Pass-Through_signals--
			  ADV => ADV,
			  LB => LB,
			  UB => UB,
			  CE => CE,
			  OE => OE, 
		      WE => WE,
		      ADDRESS => ADDRESS,
		      DATA => DATA
			  );
			  
clk_process :process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

stim_proc : process
    begin
        wait for 100 ns;
        RESET_BUTTON_d <= '0';
        wait for 900 ns;
        WRITE_BUTTON_d <= '1';
        wait for 100 ns;
        WRITE_BUTTON_d <= '0';
                wait for 100 ns;
                WRITE_BUTTON_d <= '1';
                wait for 100 ns;
                WRITE_BUTTON_d <= '0';
                wait for 600 ns;
                WRITE_BUTTON_d <= '1';
                wait for 100 ns;
                WRITE_BUTTON_d <= '0';
                wait for 100 ns;
                WRITE_BUTTON_d <= '1';
                wait for 100 ns;
                WRITE_BUTTON_d <= '0';
                wait for 600 ns;
                WRITE_BUTTON_d <= '1';
                wait for 100 ns;
                WRITE_BUTTON_d <= '0';
                wait for 100 ns;
                WRITE_BUTTON_d <= '1';
                wait for 100 ns;
                WRITE_BUTTON_d <= '0';
                --WRITE_BUTTON_d <= '1';
                wait for 3000 ns;
                --WRITE_BUTTON_d <= '0';
                wait for 8000 ns;
                --WRITE_BUTTON_d <= '1';
                --READ_BUTTON_d <= '1';
                --wait for 100 ns;
                --WRITE_BUTTON_d <= '0';
                --READ_BUTTON_d <= '0';
        --wait for 8000ns;
        --READ_BUTTON_d <= '1';
        --wait for 100 ns;
        --DATA_SWITCH_8_BIT_d <= DATA_SWITCH_8_BIT_d + 1;
        --READ_BUTTON_d <= '0';
        wait for 500 ns;
end process;
       
end Behavioral;
