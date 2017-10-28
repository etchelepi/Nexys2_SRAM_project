----------------------------------------------------------------------------------
-- Engineer: Evan Tchelepi
-- Create Date: 05/07/2013 10:38:40 PM
-- Module Name: CTRL_TB - Behavioral
-- Target Devices: Spartan 3E
-- Tool Versions: 14.4
-- Description: Test Bench for the CTRL state machine to test in Behavioral Sim
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE std.textio.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CTRL_TB is
end CTRL_TB;



architecture Behavioral of CTRL_TB is

--FILE IO TYPES--
FILE datainfile:text OPEN read_mode IS "C:\Zeta\Memory_SRAM\stim.txt";

--END FILE IO--

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

--Delcare inputs and init them--

signal clk : std_logic := '0';
signal Sensor_Data  : std_logic_vector(1 downto 0) := "00";
Signal Sensor_Enable  : std_logic := '0';
signal Memory_address  : std_logic_vector(23 downto 1) := "00000000" & "00000000" & "0000000";
signal MCU_Enable  : std_logic := '0';


--Declare outputs
signal Write_read_sel : std_logic;
signal MCU_Data  : std_logic_vector(7 downto 0);
signal LB : std_logic;
signal UB : std_logic;
signal CE : std_logic;
signal OE : std_logic;
signal WE : std_logic;
signal ADDRESS : std_logic_vector(23 downto 1);
signal DATA : std_logic_vector(15 downto 0);

constant clk_period : time := 20 ns;



begin

uut: CTRL PORT MAP ( 
              clk => clk,
              Sensor_Data  => Sensor_Data,
              Sensor_Enable => Sensor_Enable,
			  MCU_Data => MCU_Data,
			  MCU_Enable => MCU_Enable,
			  Write_read_sel => Write_read_sel,
			  
			  --Pass-Through_signals--
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

--data_process :process
--begin
--        Sensor_Enable <= '1'; 
--    for i in 1 to 1 loop
--    --11 01 11 10 10 10 11 01
        
--        Sensor_Data <= "11";--D
--        wait for 20 ns;
--        Sensor_Data <= "01";
--        wait for 20 ns;
--        Sensor_Data <= "11";--E
--        wait for 20 ns;
--        Sensor_Data <= "10";
--        wait for 20 ns;
--        Sensor_Data <= "10";--A
--        wait for 20 ns;
--        Sensor_Data <= "10";
--        wait for 20 ns;
--        Sensor_Data <= "11";--D
--        wait for 20ns;
--        Sensor_Data <= "01";
--    end loop;
--    wait for 20 ns;
--    Sensor_Enable <= '0';
--    Sensor_Data <= "00";
--    Wait for 500ns;
   
--end process; 

stim_proc : process
    begin
        
        Write_read_sel <= '0';
        --Sensor_Enable <= '1'; 
        --wait for 500 ns; 
        --Sensor_Enable <= '0';
        wait for 900 ns; 
        Write_read_sel <= '1';
        wait for 900 ns;
end process;

--FILE IO PROCESS--
PROCESS
    -- file variables
    VARIABLE vDatainline : line;
    VARIABLE vDatain     : bit_vector(1 DOWNTO 0);

  BEGIN

    FOR i IN 0 TO 39 LOOP                             -- will read 8 lines
      WAIT UNTIL (clk'event AND clk = '1');      -- on every rising edge..
      Sensor_Enable <= '1';
      readline (datainfile, vDatainline);            -- read a line from input file
      read (vDatainline, vDatain);                   -- read the first 8 bits from the line
      Sensor_Data <= To_StdLogicVector(vDatain);       -- send to data input
    END LOOP;
    wait for 20ns; --Finish Current Data
    Sensor_Enable <= '0';
    wait for 1000ns;
    FOR i IN 0 TO 39 LOOP                             -- will read 8 lines
      WAIT UNTIL (clk'event AND clk = '1');      -- on every rising edge..
        if (Write_read_sel = '1') then --this is simulating data off the chip
          readline (datainfile, vDatainline);            -- read a line from input file
          read (vDatainline, vDatain);                   -- read the first 8 bits from the line 
          --DATA <= To_StdLogicVector(vDatain);       -- send to data input
        end if;
    END LOOP;

  END PROCESS;
        
        

end Behavioral;
