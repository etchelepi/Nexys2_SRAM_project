----------------------------------------------------------------------------------
-- Engineer:  Evan Tchelepi
-- 
-- Create Date: 06/03/2013 11:34:40 PM
-- Design Name: 
-- Module Name: Mem_block_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This is part of a test bench for the mem block.
-- Revision:
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mem_block_TB is
    Port ( );
end Mem_block_TB;

architecture Behavioral of Mem_block_TB is

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
		 CTRL_RST_ADDRESS : in STD_LOGIC;

		 
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

begin


end Behavioral;
