----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Evan Tchelepi
-- Create Date:    18:31:01 05/06/2013 
-- Module Name:    CTRL - Behavioral 
-- Target Devices: Spartan 3E
-- Tool versions: 14.4
-- Description: 
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CTRL is
    Port ( clk : in  STD_LOGIC;
           Sensor_Data : in  STD_LOGIC_VECTOR (1 downto 0);
           Sensor_Enable : in  STD_LOGIC;
			  MCU_Data : out STD_LOGIC_VECTOR (7 downto 0);
			  MCU_Enable :in STD_LOGIC;
			  Write_read_sel : in STD_LOGIC;
			  
			  --Pass-Through_signals--
			  LB : out STD_LOGIC; --Lowerbyte
			  UB : out STD_LOGIC; --Upperbyte
			  CE : out STD_LOGIC; --Chip enable
			  OE : out STD_LOGIC; --Out Enable Used for Read
		     WE : out STD_LOGIC; --Write Enable Used for Write
		     ADDRESS : out STD_LOGIC_VECTOR(23 downto 1); --The 24 bit address line
		     DATA : inout STD_LOGIC_VECTOR(15 downto 0) --Data Bus Word mode
			  );
end CTRL;

architecture Behavioral of CTRL is

COMPONENT fifo_16_to_8
  PORT (
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END COMPONENT;

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

signal Fifo_To_Mem : std_logic_vector (15 downto 0);
signal Mem_To_Fifo : std_logic_vector (15 downto 0);
signal CTRL_ADDRESS_reg : std_logic_vector (23 downto 0);
signal Write_In_Fifo_empty_reg : std_logic;
signal Read_Out_Fifo_Full_Reg : std_logic;
signal CTRL_enable_reg : std_logic;
signal CTRL_mode_reg : std_logic;
signal Write_In_Fifo_rd_en_reg : std_logic;
signal Read_Out_Fifo_wr_en_reg : std_logic;
signal ctrl_data_in_fifo_en_reg : std_logic;
signal ctrl_data_out_fifo_en_reg : std_logic;
signal UNUSED_FULL : std_logic;
signal UNUSED_EMPTY : std_logic;


begin

--Read From The Memory
Read_Out_Fifo_U1 : Fifo_16_to_8
  PORT MAP (
    wr_clk => clk,
    rd_clk => clk,
    din => Mem_To_Fifo, --Data From Memory 16 bit
    wr_en => ctrl_data_out_fifo_en_reg,
    rd_en => MCU_Enable,
    dout => MCU_Data, --Data to MCU 8 bit
    full => Read_Out_Fifo_Full_Reg,
    empty => UNUSED_EMPTY
  );

--Write To the Memory
Write_In_Fifo_U2 : fifo_2_to_16 --2 bit to 16 bit write in Fifo
  PORT MAP (
    wr_clk => clk, --50mhz input clk
    rd_clk => clk, --50 Mhz output clk
    din => Sensor_Data, --2 bit data from sensor
    wr_en => Sensor_Enable, -- 2 bit data in
    rd_en => ctrl_data_in_fifo_en_reg, --16 data out
    dout => Fifo_To_Mem,
    full => UNUSED_FULL,
    empty => Write_In_Fifo_empty_reg
  );

Mem_Block : Memory_Block PORT MAP (
	clk_50mhz  => clk,
	CTRL_ENABLE => CTRL_enable_reg,
	CTRL_MODE => CTRL_mode_reg,
	CTRL_DATA_IN => Fifo_To_Mem,
	CTRL_DATA_IN_FIFO_ENABLE => ctrl_data_in_fifo_en_reg,
	CTRL_DATA_IN_FIFO_EMPTY => Write_In_Fifo_empty_reg ,
	CTRL_DATA_OUT => Mem_To_Fifo,
	CTRL_DATA_OUT_FIFO_ENABLE => ctrl_data_out_fifo_en_reg,
	CTRL_DATA_OUT_FIFO_FULL => Read_Out_Fifo_Full_Reg,
	CTRL_RST_ADDRESS => '0',

	LB => LB,
	UB => UB,
	CE => CE,
	OE => OE,
	WE => WE,
	ADDRESS => ADDRESS,
	DATA => DATA);

CTRL_mode_reg <= Write_read_sel;

--Read Write Select Process
 process (clk)
  begin
   if clk'event and clk = '1' then
	 if Write_read_sel = '0' then -- Write --
        if Write_In_Fifo_empty_reg  = '0' then --If the fifo is not empty
           --Write_In_Fifo_rd_en_reg <= ctrl_data_in_fifo_en_reg; --We enable the fifo only durring the Data Capture Cycle
		   -- Write_In_Fifo_rd_en_reg <= '1'; --enable the read register to write to mem
           --CTRL_mode_reg <= '0'; --Set to Write
	       CTRL_enable_reg <= '1'; --enable the Mem interface
	     else
		   --CTRL_mode_reg <= '0'; --Set to Write
         CTRL_enable_reg <= '0'; --enable the Mem interface
      end if;
	elsif  Write_read_sel = '1' then -- Read --
		if Read_Out_Fifo_Full_Reg = '0' then --If the fifo is not full
		  --Read_Out_Fifo_wr_en_reg <= ctrl_data_out_fifo_en_reg; --We enable the fifo only durring the Read State
		  --Read_Out_Fifo_wr_en_reg <= '1'; --enable wr register to read from memory --Maybe this should be done in the read register.
           --CTRL_mode_reg <= '1'; --Set memory contreoller to read
	       CTRL_enable_reg <= '1'; --enable the Mem interface
	     else
			 --CTRL_mode_reg <= '1'; --
	       CTRL_enable_reg <= '0'; --enable the Mem interface
      end if;
   end if;
	end if;
  end process;
  
--Concurrent assgiments--


end Behavioral;

