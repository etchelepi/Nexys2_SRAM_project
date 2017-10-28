----------------------------------------------------------------------------------
-- Engineer: Evan Tchelepi
-- Create Date: 08/15/2013 08:16:53 PM
-- Design Name: 
-- Module Name: Data_Generator - Behavioral
-- Target Devices: Spartan 3E
-- Tool Versions: 14.4
-- Description: This Function is to generate false data out over a 16 bit bus.
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Data_Generator is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           Sensor_Enable : out STD_LOGIC;
           data_2bit : out STD_LOGIC_VECTOR (1 downto 0));
end Data_Generator;

architecture Behavioral of Data_Generator is

signal false_data : std_logic_vector (15 downto 0) := "0000000000000000";
signal Sensor_Enable_i : std_logic := '0';

signal counter : integer range 0 to 7 := 0;
signal run_total : integer range 0 to 16 := 0;

begin

Data_Generator_Process: process (rst, clk) begin
	if(clk'event and clk = '1') then
		if(rst = '1') then  -- we do a reset right here first
			false_data <= "00000000" & "00000000";
			counter <= 0;
			run_total <= 0;
			Sensor_Enable <= '0';
			
		elsif(run_total < 16) then--If we are less then the run total
		    sensor_enable <= '1';
			if(counter = 7) then
				false_data <= false_data +1; -- add one to the total every 8
				counter <= 0;
			else
				counter <= counter + 1;
			end if;
			--Lets try this
			case  counter  is
				when 0 =>
					data_2bit <= false_data(15 downto 14);
				when 1 =>
					data_2bit <= false_data(13 downto 12);
				when 2 =>
					data_2bit <= false_data(11 downto 10);
				when 3 =>
					data_2bit <= false_data(9 downto 8);
				when 4 =>
					data_2bit <= false_data(7 downto 6);
				when 5 =>
					data_2bit <= false_data(5 downto 4);
				when 6 =>
					data_2bit <= false_data(3 downto 2);
				when 7 =>
					data_2bit <= false_data(1 downto 0);
				when others =>
					null;
			end case;
		else
		  data_2bit <= "00";
		  Sensor_Enable <= '0';
		end if;
	end if;
end process;

end Behavioral;
