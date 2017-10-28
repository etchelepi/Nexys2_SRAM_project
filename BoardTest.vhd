----------------------------------------------------------------------------------
-- Engineer: Evan Tchelepi
-- Create Date: 05/10/2013 10:53:20 PM
-- Module Name: BoardTest - Behavioral
-- Target Devices: Spartan 3E
-- Tool Versions: 
-- Description: This simply wrote to all the addresses and then read them out. To verify that the CTRL logic worked as intended
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



--Board test is a function that will do two functions. It will write X addresses to memory and then read back that address and compare the values. It will do this through all the address
--possible which would be 8 million.

--Lets just write all 8 million bytes to the chip, then read them back.

entity BoardTest is
    Port ( clk : in  STD_LOGIC;
           LEDS_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           clk_out : out STD_LOGIC;
    
        --PASS SIGNALS TO FPGA 
        ADV : out STD_LOGIC; --adv
        LB : out STD_LOGIC; --Lowerbyte
        UB : out STD_LOGIC; --Upperbyte
    	CE : out STD_LOGIC; --Chip enable
        OE : out STD_LOGIC; --Out Enable Used for Read
        WE : out STD_LOGIC; --Write Enable Used for Write
    	ADDRESS : out STD_LOGIC_VECTOR(23 downto 1); --The 24 bit address line
    	DATA : inout STD_LOGIC_VECTOR(15 downto 0) --Data Bus Word mode
    			  );
end BoardTest;

architecture Behavioral of BoardTest is

-- State values for the Write State Machine
type state_type is (Case_Start_seq, Case_Send_0_1, Case_Send_2_3,Case_Send_4_5,Case_Send_6_7,Case_Send_8_9,Case_Send_10_11,Case_Send_12_13,Case_Send_14_15,Case_Increment_sensor_data,State_Read_start,State_Read_wait,State_read_Delay_icr); 
signal State_Current, State_Next : state_type;

COMPONENT BoardDCM is
   port ( CLKIN_IN        : in    std_logic; 
          RST_IN          : in    std_logic; 
          CLKDV_OUT       : out   std_logic; 
          CLKIN_IBUFG_OUT : out   std_logic; 
          CLK0_OUT        : out   std_logic; 
          LOCKED_OUT      : out   std_logic);
end COMPONENT;

COMPONENT CTRL is
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
end COMPONENT;

signal Read_Delay_Count : STD_LOGIC_Vector (31 downto 0) :=  "00000000" & "00000000" & "00000000" & "00000000";
signal Sensor_Data_16_bit : STD_LOGIC_VECTOR (23 downto 0) := "00000000" & "10101010" & "10101010";
signal count : STD_LOGIC_VECTOR(23 downto 1);
signal generated_sensor_data : STD_LOGIC_VECTOR (1 downto 0);
signal Sensor_enable_reg : STD_LOGIC;
signal Write_Read_Mode_reg : STD_LOGIC := '0'; --Default is write
signal MCU_Enable_reg : STD_LOGIC := '0';
signal MCU_Data_reg : STD_LOGIC_VECTOR (7 downto 0);

signal locked : STD_LOGIC;
signal rst : STD_LOGIC;
signal IBUFG : STD_LOGIC;
signal clk_x : STD_LOGIC;

begin

--Clocking element--
Clock_Manager : BoardDCM PORT MAP ( 
          CLKIN_IN => clk,
          RST_IN => '0',
          CLKDV_OUT => clk_out,
          CLKIN_IBUFG_OUT => open,
          CLK0_OUT => clk_x,
          LOCKED_OUT => open );

--The Control Module:

Test_CTRL_block : CTRL PORT MAP ( 
              clk => clk_x,
              Sensor_Data  => generated_sensor_data,
              Sensor_Enable => Sensor_enable_reg,
			  MCU_Data => MCU_Data_reg,
			  MCU_Enable => MCU_Enable_reg,
			  Write_read_sel => Write_Read_Mode_reg,
			  
			  --Pass-Through_signals--
			  LB => LB,
			  UB => UB,
			  CE => CE,
			  OE => OE, 
		      WE => WE,
		      ADDRESS => ADDRESS,
		      DATA => DATA
			  );


--This is State Changing State--
process (clk_x)
  begin
   if clk_x = '1' and clk_x'Event then
    State_Current <= State_Next;
   end if;
  end process;
  

--Data Send StateMachine
--
--This State Machine procceds to create a data input at 50Mhz that represents two input lines
--We write a 24 bit number's lower 16 bits. The reason for this is to be able to compare this value
--Later when we read it out to make sure that the data was written to correctly
  
process (State_Current) begin
 
case State_Current is

   when Case_Start_seq =>
   Sensor_enable_reg <= '0';
        State_Next <= Case_Send_0_1;
        
   --Send_0_1
   when Case_Send_0_1 => --0ns
        Sensor_enable_reg <= '1'; -- Write Data while valid
        generated_sensor_data <= Sensor_Data_16_bit (15 downto 14);
        State_Next <= Case_Send_2_3;
        LEDS_OUT <= "10101011";
   --Send_2_3
   when Case_Send_2_3 => --20ns
           Sensor_enable_reg <= '1';
           generated_sensor_data <= Sensor_Data_16_bit(13 downto 12);
           State_Next <= Case_Send_4_5;
           LEDS_OUT <= "10000001";
   --Send_4_5
   when Case_Send_4_5 => --40ns
           Sensor_enable_reg <= '1';
           generated_sensor_data <= Sensor_Data_16_bit(11 downto 10);
           State_Next <= Case_Send_6_7;
           LEDS_OUT <= "10000011";   
   --Send_6_7
   when Case_Send_6_7 => --60ns
           Sensor_enable_reg <= '1';
           generated_sensor_data <= Sensor_Data_16_bit(9 downto 8);
           State_Next <= Case_Send_8_9;
           LEDS_OUT <= "10000101"; 
   --Send_8_9
   when Case_Send_8_9 =>--80ns
           Sensor_enable_reg <= '1';
           generated_sensor_data <= Sensor_Data_16_bit(7 downto 6);
           State_Next <= Case_Send_10_11;
           LEDS_OUT <= "10001001";  
   --Send_10_11
   when Case_Send_10_11 => --100ns
           Sensor_enable_reg <= '1';
           generated_sensor_data <= Sensor_Data_16_bit(5 downto 4);
           State_Next <= Case_Send_12_13;
           LEDS_OUT <= "10010011";
   --Send_12_13
   when Case_Send_12_13 => --120ns
           Sensor_enable_reg <= '1';
           generated_sensor_data <= Sensor_Data_16_bit(3 downto 2);
           State_Next <= Case_Send_14_15;
           LEDS_OUT <= "10100111";  
   --Send_14_15
   when Case_Send_14_15 => --140ns
           Sensor_enable_reg <= '1';
           generated_sensor_data <= Sensor_Data_16_bit(1 downto 0);
           State_Next <= Case_Increment_sensor_data;
           LEDS_OUT <= "11001111";
   when Case_Increment_sensor_data => --160ns
        Sensor_enable_reg <= '0'; -- Disable while we incrament
        if(Sensor_Data_16_bit = "11111111" & "11111111" & "11111111") then --8,388,607 -00011111111111111111111
                Write_Read_Mode_reg <= '1'; --Read Mode Set
                LEDS_OUT <= "01010101";
                State_Next <= State_Read_Start;
        else
            Sensor_Data_16_bit <= Sensor_Data_16_bit + 1;
            LEDS_OUT <= "11000111";
            State_Next <= Case_Send_0_1;
        end if;
        
    --Read States    
    when State_Read_Start =>
        MCU_Enable_reg <= '1'; --Lets read a value out of the fifo
        LEDS_OUT <= MCU_Data_reg; -- Output the Value to the LEDS
        --LEDS_OUT <= "11111111";
        State_Next <= State_Read_Wait;
    --Wait 200ms approx to read the next value. This shows if it is working on the LEDs
    when State_Read_Wait =>
        MCU_Enable_reg <= '0';
        --if (Read_Delay_Count < 1000) then --10 million in hex x989680
            --State_Next <= State_read_Delay_icr;
            --Read_Delay_Count <= Read_Delay_Count + 1;
            --LEDS_OUT <= "01010101";
            LEDS_OUT <= MCU_Data_reg; -- Output the Value to the LEDS
        --else
            --Read_Delay_Count <= "00000000" & "00000000" & "00000000" & "00000000";
            State_Next <= State_Read_Start;
            --LEDS_OUT <= "10101010";
       --end if;
    --Test
    when State_read_Delay_icr =>
         State_Next <= State_Read_wait;
         Read_Delay_Count <= Read_Delay_Count + 1;
   end case;
end process;

ADV <= '0';

--Time to Mux between Write and Read so they do not overwrite eachother: 
--process (clk) begin
--    --When We have written to 8 million Reads
--    if(Sensor_Data_16_bit = "11111111111111111111111") then --8,388,607
--        Write_Read_Mode_reg <= '1'; --Read Mode Set
--    end if;
--end process;



--Data Read State Machine
--This stage we wait for the count to reach 8 million. This means all the locations on the 16MB SRAM have been written to
--At this point what we do is read out the values from memory with the read option. We compare the value to the address
--If they match we move on, otherwise we issue an error
--The address should match the memory location

--process (clk, Current_Read_State) begin
 
--    case Current_Read_State is 
--        when State_Wait_For_Read =>
--            if Write_Read_Mode_reg <= '0' then -- When write mode we sit and do nothing!
--                Next_Read_State <= State_Wait_For_Read;
--            else
--                Next_Read_State <= State_Read_Start;
               
--        --Bascially we read from the Fifo for read
--        when State_Read_Start =>
--            MCU_Enable <= '1'; --Lets read a value out of the fifo
--            LEDS_OUT <= MCU_Data_reg; -- Output the Value to the LEDS
--            Next_Read_State <= State_Read_Wait;
--        --Wait 200ms approx to read the next value. This shows if it is working on the LEDs
--        when State_Read_Wait =>
--            MCU_Enable <= '0';
--            if Read_Delay_Count < "x989680" then --10 million in hex
--                Next_Read_State <= State_Read_wait;
--            else
--                Read_Delay_Count <= "x00000000";
--                Next_Read_State <= State_Read_Start;
--             end if;  
             
--    end case;
--end process;	    		

end Behavioral;
