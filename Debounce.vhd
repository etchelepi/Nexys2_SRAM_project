----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Evan Tchelepi
-- 
-- Create Date: 07/17/2013 10:14:16 AM
-- Design Name: 
-- Module Name: Debounce_Top - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Debounce is
    Port ( input_button : in STD_LOGIC;
           output_pulse : out STD_LOGIC;
           clk : in STD_LOGIC);
end Debounce;

architecture Behavioral of Debounce is

signal debounce_cnt : integer :=0;
signal enable_i : std_logic := '1';
signal release_i : std_logic := '0';

begin

Counter: process (clk,input_button,enable_i,release_i)
    begin
        if(clk'event and clk='1') then
            debounce_cnt <=debounce_cnt+1;
            --If we are enabled AND we get a button pulse we go into a disabled mode
            --and reset the counter becase we are about to count
            if( input_button = '1' AND enable_i = '1' AND release_i = '0') then
                debounce_cnt <= 1; --reset the debounce counter
                enable_i <= '0'; -- Disable the button
                output_pulse <= '1';
                release_i <= '1';--We don't want to switch until the button is released
            --Else we wait for the renable conditions
            elsif (input_button = '0' AND enable_i = '1' AND release_i = '1') then
                release_i <= '0';
            else 
                output_pulse <= '0';
                if( debounce_cnt > 5) then
                    enable_i <= '1';
                    debounce_cnt <= 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
