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
-- Description: This mux generate control signals required fot writing operation to memory 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
 use work.rlwe_pkg.all;
entity mem_ctrl_mux is
    generic (
    mux_dw:   integer range 1 to 64
 );
 port( 
     I0,I1,I2,I3,I4,I5,I6,I7 : in STD_LOGIC_vector(mux_dw-1 downto 0);
     S: in STD_LOGIC_vector(2 downto 0);
     O: out STD_LOGIC_vector(mux_dw-1 downto 0)
  );
end mem_ctrl_mux;
 
architecture bhv of mem_ctrl_mux is
begin
process (I0,I1,I2,I3,I4,I5,I6,I7, S) is
begin
  if (S ="000") then
      O <= I0;
  elsif (S="001") then
      O <= I1;
  elsif (S ="010") then
      O <= I2;
  elsif (S="011") then
       O <= I3;
  elsif (S ="100") then
       O <= I4;
   elsif (S ="101") then
        O <= I5;
   elsif (S="110") then
       O <= I6;
  else
      O <= I7;
  end if;
 
end process;
end bhv;
