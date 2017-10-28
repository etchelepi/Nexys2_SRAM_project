----------------------------------------------------------------------------------
-- Engineer: Evan Tchelepi
-- Create Date: 05/29/2013 11:23:48 PM
-- Module Name: Memory_Block - Behavioral
-- Target Devices: Spatan 3E
-- Tool Versions: 14.4
-- Description: 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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

entity Memory_Block is
    Port(
         clk_50mhz  : in std_logic;       -- 50Mhz Clk
		 --Signals to CTRL block
		 CTRL_ENABLE : in STD_LOGIC;
		 CTRL_MODE : in STD_LOGIC; -- '1' = Read '0' = Write
		 CTRL_DATA_IN : in STD_LOGIC_VECTOR (15 downto 0);
		 CTRL_DATA_IN_FIFO_ENABLE : out STD_LOGIC; --We want to enable the data we wish to save to Memory
		 CTRL_DATA_IN_FIFO_EMPTY : in STD_LOGIC; -- We Want to make sure the FIFO is not EMPTY when we read from it
		 CTRL_DATA_OUT : out STD_LOGIC_VECTOR (15 downto 0);
		 CTRL_DATA_OUT_FIFO_ENABLE : out STD_LOGIC;
		 CTRL_DATA_OUT_FIFO_FULL : in STD_LOGIC; --We want to make sure the fifo is not full when we write to it
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
       
end Memory_Block;

architecture Behavioral of Memory_Block is

--State Machine names and state signals
type state_type is (State_IDLE, State_Read_Start,State_Read_Wait,State_Read_Data_Set,State_Read_Finish,State_Write_Start,State_Write_Wait,State_Write_Data_Set,State_Write_Finish); 
signal state, next_state : state_type; 

--State Machine output signals
signal LB_i : STD_LOGIC := '0'; --Lowerbyte
signal UB_i : STD_LOGIC := '0'; --Upperbyte
signal CE_i : STD_LOGIC := '0'; --Chip enable
signal OE_i : STD_LOGIC := '0'; --Out Enable Used for Read
signal WE_i : STD_LOGIC := '1'; --Write Enable Used for Write
signal ADDRESS_i : STD_LOGIC_VECTOR(23 downto 1) := "00000000" & "00000000" & "0000000"; --The 24 bit address line

-- Counter used to generate delays
signal Delay_Cnt : std_logic_vector(4 downto 0);

begin

--Data gets the registered Data signal when Write Mode, otherwise High Impedence
DATA <=  CTRL_DATA_IN when CTRL_MODE = '0' else "ZZZZZZZZ" & "ZZZZZZZZ"; --for write
--CTRL_DATA_OUT <= DATA; -- We set the data to be read out

--IO <= I when T = '0' else 'Z';
--	O_NEW <= IO;
	
LB <= LB_i;
UB <= UB_i;
CE <= CE_i;
OE <= OE_i;
WE <= WE_i;
ADDRESS <= ADDRESS_i;
 
--Insert the following in the architecture after the begin keyword
   SYNC_PROC: process (clk_50mhz)
   begin
      if (clk_50mhz'event and clk_50mhz = '1') then
            state <= next_state;
            -- assign other outputs to internal signals      
            --LB <= LB_i;
            --UB <= UB_i;
            --CE <= CE_i;
            --OE <= OE_i;
            --WE <= WE_i;
            --ADDRESS <= ADDRESS_i;

      end if;
   end process;
   
 -------------------------------------------------------------------------------
 --MOORE State-Machine - Outputs based on state only
 -------------------------------------------------------------------------------
   OUTPUT_DECODE: process (state,DATA,CTRL_DATA_IN,CTRL_ADDRESS_READ,CTRL_ADDRESS_WRITE)
   begin
  
    --------------------------------------------------------------
    -- START CE OE WE LB UB SECTION
    --------------------------------------------------------------
     if (state = State_Read_Start or state = State_Read_Wait or state = State_Read_Data_Set) then
         CE_i <= '0';
         OE_i <= '0';
         WE_i <= '1';
         LB_i <= '0';
         UB_i <= '0';
         ADDRESS_i <= CTRL_ADDRESS_READ;
     --Lets choose our outputs for a Write Opeartion
     elsif (state = State_Write_Start or state = State_Write_Wait or state= State_Write_Data_Set) then
         CE_i <= '0';
         OE_i <= '0';
         WE_i <= '0';
         LB_i <= '0';
         UB_i <= '0';
     --Everything else should default to the not operational values
     else
        CE_i <= '1';
        OE_i <= '1';
        WE_i <= '1';
        LB_i <= '0';
        UB_i <= '0';     
     end if;
    --------------------------------------------------------------
    -- END CE OE WE LB UB SECTION
    --------------------------------------------------------------

    --------------------------------------------------------------
    -- Start Address value Section
    -- We choose which states use the READ address provided, or which states
    -- Use the WRITE state provided. If we are in a state that is not
    -- Covered we will just write out ZERO/FFFF depending which makes more sense
    -- In the design at that point
    --------------------------------------------------------------
    if (state = State_Write_Start or state = State_Write_Wait  or state = State_Write_Data_Set or state = State_Write_Finish) then
    	ADDRESS_i <= CTRL_ADDRESS_WRITE;	
    elsif (state = State_Read_Start or state = State_Read_Wait or state = State_Read_Data_Set or state= State_Read_Finish ) then
        ADDRESS_i <= CTRL_ADDRESS_READ;
    elsif (state = State_IDLE) then -- Mantain address durring an idle state
        ADDRESS_i <= ADDRESS_i;
    else
        ADDRESS_i <= "00000000" & "00000000" & "0000000"; --In unknown states we set it to zero
    end if;
    --------------------------------------------------------------
    -- END Address value Section
    --------------------------------------------------------------
    
    --------------------------------------------------------------
    -- START FIFO ENABLE SECTION
    --------------------------------------------------------------
    if (state = State_Write_Start) then -- Was State_Write_Finish
    	CTRL_DATA_IN_FIFO_ENABLE <= '1'; -- Enable the fifo when we are writing the data to memory.
    	CTRL_DATA_OUT_FIFO_ENABLE <= '0'; --Turn it off
    elsif(state = State_Read_Start) then -- Was State_Read_Finish
        CTRL_DATA_OUT_FIFO_ENABLE <= '1'; --Enable the fifo for when we write the Data back from memory.
    	CTRL_DATA_IN_FIFO_ENABLE <= '0'; -- Turn it off
    else
        CTRL_DATA_OUT_FIFO_ENABLE <= '0'; --turn it off
        CTRL_DATA_IN_FIFO_ENABLE <= '0'; -- Turn it off
    end if;
    --------------------------------------------------------------
    -- END FIFO ENABLE SECTION
    --------------------------------------------------------------
    
    --------------------------------------------------------------
    -- START DATA in/out from Memory SECTION
    --------------------------------------------------------------
    if (state = State_Read_Finish) then
       CTRL_DATA_OUT <= DATA; -- We set the data to be read out -- Data is valid turning the finish state
    end if;
    
    if (state = State_Write_Finish) then
        --This is taken care of by the orginal logic above. We only care
        --About the Data being read becuase it needs to be assgined a direction
        --Later Data_in needs to be taken care of.
        --DATA <= CTRL_DATA_IN; --We output the value to be
    end if;
    --------------------------------------------------------------
    -- START DATA in/out from Memory SECTION
    --------------------------------------------------------------

   end process;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------   
   NEXT_STATE_DECODE: process (state,CTRL_DATA_IN_FIFO_EMPTY, CTRL_DATA_OUT_FIFO_FULL,Delay_Cnt,CTRL_ENABLE,CTRL_MODE)
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      --insert statements to decode next_state
      --below is a simple example
      case (state) is
         ------------------------ 
         when State_IDLE =>
            if CTRL_ENABLE = '1' then --We need to preform a read/write operation
                if CTRL_MODE = '0' then --We choose to do a write operation
                    if (CTRL_DATA_IN_FIFO_EMPTY = '0') then
                       next_state <=  State_Write_Start;
                    else
                        next_state <= State_IDLE;
                    end if;
                else -- We choose to do a Read operation
                    if(CTRL_DATA_OUT_FIFO_FULL = '0') then --While the fifo is not full we can write to it
                        next_state <=  State_Read_Start;
                    else
                        next_state <= State_IDLE;
					end if;
                end if;
            else
                next_state <=  State_IDLE;
            end if;
-------------------------------------------------------------------------------
-- READ STATES	
-------------------------------------------------------------------------------
         when State_Read_Start =>
               next_state <= State_Read_Wait;
         ------------------------ 
         when State_Read_Wait =>
            if Delay_Cnt = "00010" then -- wait 3 cycles
                next_state <= State_Read_Finish;
            else
                next_state <= State_Read_Wait;
            end if;
        ------------------------ 
        when State_Read_Data_Set =>
            next_state <= State_Read_Finish;
         ------------------------ 
         when State_Read_Finish =>
            if CTRL_ENABLE = '1' then --We need to preform a read/write operation
                 if CTRL_MODE = '0' then --We choose to do a write operation
                     if (CTRL_DATA_IN_FIFO_EMPTY = '0') then
                        next_state <=  State_Write_Start;
                     else
                         next_state <= State_IDLE;
                     end if;
                 else -- We choose to do a Read operation
                     if(CTRL_DATA_OUT_FIFO_FULL = '0') then --While the fifo is not full we can write to it
                         next_state <=  State_Read_Start;
                     else
                         next_state <= State_IDLE;
							end if;
                 end if;
				 else
                next_state <=  State_IDLE;
             end if;
-------------------------------------------------------------------------------
-- WRITE STATES	
-------------------------------------------------------------------------------
         when State_Write_Start =>
               next_state <= State_Write_Wait;
         ------------------------ 
         when State_Write_Wait =>
            if Delay_Cnt = "00001" then -- wait 3 cycles
                next_state <= State_Write_Data_Set;
            else
                next_state <= State_Write_Wait;
            end if;
         ------------------------ 
			when State_Write_Data_Set =>
				next_state <= State_Write_Finish;
			------------------------ 
         when State_Write_Finish =>
           if CTRL_ENABLE = '1' then --We need to preform a read/write operation
                 if CTRL_MODE = '0' then --We choose to do a write operation
                     if (CTRL_DATA_IN_FIFO_EMPTY = '0') then
                        next_state <=  State_Write_Start;
                     else
                         next_state <= State_IDLE;
                     end if;
                 else -- We choose to do a Read operation
                     if(CTRL_DATA_OUT_FIFO_FULL = '0') then --While the fifo is not full we can write to it
                         next_state <=  State_Read_Start;
                     else
                         next_state <= State_IDLE;
							end if;
                 end if;
				else
                next_state <=  State_IDLE;
            end if;
-------------------------------------------------------------------------------
-- OTHER	
------------------------------------------------------------------------------- 
         when others =>
            next_state <= State_IDLE;
      end case;      
   end process;

------------------------------------------------------------------------
-- Delay Counter
------------------------------------------------------------------------			
   process (clk_50mhz)
    begin
     if clk_50mhz'event and clk_50mhz = '1' then
      if state = State_Write_Start or state = State_IDLE or state = State_Read_Start then
       Delay_Cnt <= "00000";
      else
       Delay_Cnt <= Delay_Cnt + 1;
      end if;
     end if;
    end process;

end Behavioral;
