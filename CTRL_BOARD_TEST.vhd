----------------------------------------------------------------------------------
-- Engineer: Evan Tchelepi
-- Create Date: 06/03/2013 11:37:40 PM
-- Module Name: CTRL_BOARD_TEST - Behavioral
-- Target Devices: Spartan 3E
-- Tool Versions: 14.4
-- Description: This is to test the CTRL logic has a top level HDL logic.
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


entity CTRL_BOARD_TEST is

    Port ( clk_in : in  STD_LOGIC;
			  --Switch DATA
			  DATA_SWITCH_8_BIT : in STD_LOGIC_VECTOR (7 downto 0);
			  WRITE_BUTTON : in STD_LOGIC;
			  READ_BUTTON : in STD_LOGIC;
			  RESET_BUTTON : in STD_LOGIC;
			  LEDS_OUT : out STD_LOGIC_VECTOR (7 downto 0);
			  
			  --LOGIC ANALYSER SIGNALS--
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
end CTRL_BOARD_TEST;


architecture Behavioral of CTRL_BOARD_TEST is

COMPONENT BoardDCM is
   port ( CLKIN_IN        : in    std_logic; 
          RST_IN          : in    std_logic; 
          CLKDV_OUT       : out   std_logic; 
          CLKIN_IBUFG_OUT : out   std_logic; 
          CLK0_OUT        : out   std_logic; 
          LOCKED_OUT      : out   std_logic);
end COMPONENT;

COMPONENT fifo_2_to_16
  PORT (
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT write_btn_ctrl
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           fifo_ready : in STD_LOGIC;
           reset : in STD_LOGIC;
           address : out STD_LOGIC_VECTOR (23 downto 1));
end COMPONENT;

component Debounce is
    Port ( input_button : in STD_LOGIC;
           output_pulse : out STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component Data_Generator is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           Sensor_Enable : out STD_LOGIC;
           data_2bit : out STD_LOGIC_VECTOR (1 downto 0));
end component;

component Memory_Block is
  Port(
       clk_50mhz  : in std_logic;       -- 50Mhz Clk
		 --Signals to CTRL block
		 CTRL_ENABLE : in STD_LOGIC;
		 CTRL_MODE : in STD_LOGIC; -- '1' = Read '0' = Write
		 CTRL_DATA_IN : in STD_LOGIC_VECTOR (15 downto 0);
		 CTRL_DATA_IN_FIFO_ENABLE : out STD_LOGIC;
		 CTRL_DATA_IN_FIFO_EMPTY : in STD_LOGIC;
		 CTRL_DATA_OUT : out STD_LOGIC_VECTOR (15 downto 0);
		 CTRL_DATA_OUT_FIFO_ENABLE : out STD_LOGIC;
		 CTRL_DATA_OUT_FIFO_FULL : in STD_LOGIC;
		 CTRL_ADDRESS_READ : in STD_LOGIC_VECTOR (23 downto 1);
         CTRL_ADDRESS_WRITE : in STD_LOGIC_VECTOR (23 downto 1);
		 
		 --Memory Interface signals
		 LB : out STD_LOGIC; --Lowerbyte
		 UB : out STD_LOGIC; --Upperbyte
		 CE : out STD_LOGIC; --Chip enable
		 OE : out STD_LOGIC; --Out Enable Used for Read
		 WE : out STD_LOGIC; --Write Enable Used for Write
		 ADDRESS : out STD_LOGIC_VECTOR(23 downto 1); --The 24 bit address line
		 DATA : inout STD_LOGIC_VECTOR(15 downto 0) --Data Bus Word mode
       );
end component;

signal Sensor_Enable : std_logic := '0';
signal WRITE_BUTTON_i : STD_LOGIC;

--signal CTRL_ADDRESS_reg : std_logic_vector (23 downto 0);
signal Write_In_Fifo_empty_reg : std_logic := '0'; --In this test the fifo is never not empty
signal CTRL_enable_reg : std_logic;
signal CTRL_mode_reg : std_logic := '0';


signal ADDRESS_i : std_logic_vector (23 downto 1) := "00000000" & "00000000" & "0000000";
signal ADDRESS_READ_i : std_logic_vector (23 downto 1) := "00000000" & "00000000" & "0000000";
signal ADDRESS_WRITE_i : std_logic_vector (23 downto 1) := "00000000" & "00000000" & "0000000";

--signal WRITE_BUTTON_i : std_logic;
signal READ_BUTTON_i : std_logic;
signal READ_MEMORY_i : std_logic_vector (15 downto 0):= "00000000" & "00000000";
signal WRITE_MEMORY_i : std_logic_vector (15 downto 0):= "00000000" & "00000000";

signal WRITE_START_FLAG_i : std_logic := '0';
--signal active_write_i : std_logic := '0';
signal out_fifo_enable_i : std_logic;
signal in_fifo_enable_i : std_logic;

signal CE_i : std_logic;
signal OE_i : std_logic;
signal WE_i : std_logic;

signal PULSE_FLAG_READ : std_logic := '0';

signal clk : std_logic;

signal Simulated_Sensor_Data : std_logic_vector (1 downto 0) := "00";
signal CLKIN_IBUFG_OUT_UC : std_logic ;
signal LOCKED_OUT_UC : std_logic;

constant TEST_SIZE : std_logic_vector(15 downto 0) := "00000000" & "00000111";

   
begin

--We write out the switches to make it work

ADDRESS <= ADDRESS_i; -- output the real address
LA_ADDRESS <= ADDRESS_i; --output the debug address (same just different ports
GARBAGE <= WRITE_MEMORY_i;

LEDS_OUT <= Sensor_Enable & Write_In_Fifo_empty_reg & "0000" & Simulated_Sensor_Data;
--LEDS_OUT <= READ_MEMORY_i(7 downto 0);
ADV <= '0';

DEBUG_SIG_CE <= CE_i;
DEBUG_SIG_OE <= OE_i;
DEBUG_SIG_WE <= WE_i;

CE <= CE_i;
OE <= OE_i;
WE <= WE_i;

Data_generation: Data_Generator PORT MAP ( 
           clk => clk,
           rst => RESET_BUTTON,
           Sensor_Enable => Sensor_Enable,
           data_2bit => Simulated_Sensor_Data );

--Clocking element--
Clock_Manager: BoardDCM PORT MAP ( 
          CLKIN_IN => clk_in,
          RST_IN => '0',
          CLKDV_OUT => LA_CLK,
          CLKIN_IBUFG_OUT => CLKIN_IBUFG_OUT_UC,
          CLK0_OUT => clk,
          LOCKED_OUT => LOCKED_OUT_UC );

Mem_Block: Memory_Block PORT MAP (
	clk_50mhz  => clk,
	CTRL_ENABLE => CTRL_enable_reg,
	CTRL_MODE => CTRL_mode_reg,
	CTRL_DATA_IN => WRITE_MEMORY_i,
	CTRL_DATA_IN_FIFO_ENABLE => in_fifo_enable_i,
	CTRL_DATA_IN_FIFO_EMPTY => Write_In_Fifo_empty_reg,
	CTRL_DATA_OUT => READ_MEMORY_i,
	CTRL_DATA_OUT_FIFO_ENABLE => out_fifo_enable_i,
	CTRL_DATA_OUT_FIFO_FULL => '0',
   CTRL_ADDRESS_READ => ADDRESS_READ_i,
   CTRL_ADDRESS_WRITE => ADDRESS_WRITE_i ,

	LB => LB,
	UB => UB,
	CE => CE_i,
	OE => OE_i,
	WE => WE_i,
	ADDRESS => ADDRESS_i,
	DATA => DATA);
------------------------------------------------------------------


--The Write Fifo--
Write_In_Fifo_U2 : fifo_2_to_16 --2 bit to 16 bit write in Fifo
  PORT MAP (
    wr_clk => clk, --50mhz input clk
    rd_clk => clk, --50 Mhz output clk
    din => Simulated_Sensor_Data, --2 bit data from sensor
    wr_en => Sensor_Enable, -- 2 bit data in
    rd_en => in_fifo_enable_i, --16 data out
    dout => WRITE_MEMORY_i,
    full => open,
    empty => Write_In_Fifo_empty_reg
  );

Write_ctrl_U4 : write_btn_ctrl
        Port MAP 
        ( clk => clk,
          btn => WRITE_BUTTON_i, 
          fifo_ready => NOT (Write_In_Fifo_empty_reg),
          reset => '0',
          address => ADDRESS_WRITE_i
          );

Write_Debounce: Debounce
    Port MAP ( 
    input_button => WRITE_BUTTON,
    output_pulse => WRITE_BUTTON_i,
    clk => clk
    );
    
WRITE_START_FLAG_i <=  WRITE_BUTTON_i;   

Read_Debounce: Debounce
    Port MAP ( 
    input_button => READ_BUTTON,
    output_pulse => READ_BUTTON_i,
    clk => clk
    );

------------------------------------------------------------
--RESET
process (clk) 
begin
    if(clk'event and clk = '1') then
        if (RESET_BUTTON = '1') then
            ADDRESS_READ_i <= "00000000" & "00000000" & "0000000";
            --ADDRESS_WRITE_i <= "00000000" & "00000000" & "0000000";
        elsif (READ_BUTTON_i = '1' AND PULSE_FLAG_READ = '0') then
            ADDRESS_READ_i <= ADDRESS_READ_i + 1;
            PULSE_FLAG_READ <= '1';
        else
            PULSE_FLAG_READ <= '0';
        end if;
    end if;
end process;
--END RESET

-------------------------------------------------------------

--Read Write Select Process
process (clk)
  begin
   if clk'event and clk = '1' then
	 if WRITE_START_FLAG_i = '1' then -- Write button pressed--
	    CTRL_mode_reg <= '0'; --Set to Write
     	CTRL_enable_reg <= '1'; --enable the Mem interface
	  elsif  READ_BUTTON_i = '1' then -- Read button pressed--
	   --LEDS_OUT <= DATA(7 downto 0);
       CTRL_mode_reg <= '1'; --Set memory contreoller to read
	   CTRL_enable_reg <= '1'; --enable the Mem interface
	  else 
		 CTRL_enable_reg <= '0';
     end if;
   end if;
end process;
  
--Concurrent assgiments--


end Behavioral;

