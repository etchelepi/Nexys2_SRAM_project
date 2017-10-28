----------------------------------------------------------------------------------
-- Engineer: Evan Tchelepi
-- Create Date: 07/30/2013 07:40:34 PM
-- Module Name: write_btn_ctrl - Behavioral
-- Target Devices: Spartan 2E
-- Tool Versions: 14.4
-- Description: 
-- Revision 0.01 - File Created
-- Additional Comments:
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity write_btn_ctrl is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           fifo_ready : in STD_LOGIC;
           reset : in STD_LOGIC;
           address : out STD_LOGIC_VECTOR (23 downto 1));
end write_btn_ctrl;

architecture Behavioral of write_btn_ctrl is

signal count : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
signal count_i : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
signal address_Si : STD_LOGIC_VECTOR (23 downto 1);
signal address_i : STD_LOGIC_VECTOR (23 downto 1) := "00000000" & "00000000" & "0000000";

type state_type is (st_idle, st_1, st_2,st_3,st_4); 
   signal next_state, state : state_type; 

begin

address <= address_i;

addres_count_Proc: process(clk,btn,fifo_ready) begin
	if(clk'event and clk = '1') then
		if(reset = '1') then
			address_i <= "00000000" & "00000000" & "0000000";
		else
			if(btn = '1' AND fifo_ready = '1') then
				address_i <= address_i + 1;				
			end if;
		end if;
	end if;
end process;

--SYNC_PROC: process (clk)
--begin
--   if (clk'event and clk = '1') then
--      if (reset = '1') then
--         state <= st_idle;
--      else
--         state <= next_state;
--         address_S <= address_Si;
--         count <= count_i;
--      end if;        
--   end if;
--end process;

--OUTPUT_DECODE: process (state)
--    begin
--       if(state = st_idle) then
--            address_Si <= address_S;
--            count_i <= count_i;
--       elsif (state = st_1) then
--            count_i <= count_i;
--          address_Si <= address_S;
--       elsif (state = st_2) then
--          address_Si <= "0000000" & "00000000" & count;
--          count_i <= count_i +1;
--       else
--          address_Si <= address_S;
--          count_i <= count_i;
--       end if;
--    end process;

--NEXT_STATE_DECODE: process (state,btn,fifo_ready)
--   begin
--      --declare default state for next_state to avoid latches
--      next_state <= state;  --default is to stay in current state
--      --insert statements to decode next_state
--      --below is a simple example
--      case (state) is
--         when st_idle =>
--            if( btn = '1' AND fifo_ready = '1') then
--                next_state <= st_1; -- We start
--            else
--                next_state <= st_idle; --else we wait
--            end if;
--         when st_1 =>
--             next_state <= st_2; 
--         when st_2 =>
--             next_state <= st_3; 
--         when st_3 =>
--             next_state <= st_4; 
--         when st_4 =>
--             next_state <= st_idle; 
--         when others =>
--            next_state <= st_idle;
--      end case;      
--   end process;

end Behavioral;
