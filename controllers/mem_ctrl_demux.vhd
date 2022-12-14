----------------------------------------------------------------------------------
-- Company: Siksa O Anusandhan
-- Engineer: Dr. Rourab paul
-- 
-- Create Date: 22.07.2022 10:21:30
-- Design Name: 
-- Module Name: mem_ctrl_demux
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This demux generate control signals required fot reading operation from memory 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.rlwe_pkg.all;

entity mem_ctrl_dmux is
    generic (
dmux_dw:   integer range 1 to 64
);
Port ( I : in  STD_LOGIC_VECTOR (dmux_dw-1 downto 0); 
       S : in STD_LOGIC_VECTOR (2 downto 0);
       Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7 : out STD_LOGIC_VECTOR (dmux_dw-1 downto 0));

end mem_ctrl_dmux;

architecture Behavioral of mem_ctrl_dmux is
begin
process (I, S)

begin

if (S <= "000") then
 Y0 <= I ;
elsif (S <= "001") then
 Y1 <= I ;
elsif (S <= "010") then
 Y2 <= I ;
elsif (S <= "011") then
  Y3 <= I ;
 elsif (S <= "100") then
  Y4 <= I ;
 elsif (S <= "101") then
   Y5 <= I ;
 elsif (S <= "110") then
    Y6 <= I ;
 else
  Y7 <= I ;
end if;

end process;

end Behavioral;
