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
     A,B,C,D : in STD_LOGIC_vector(mux_dw-1 downto 0);
     S: in STD_LOGIC_vector(1 downto 0);
     Z: out STD_LOGIC_vector(mux_dw-1 downto 0)
  );
end mem_ctrl_mux;
 
architecture bhv of mem_ctrl_mux is
begin
process (A,B,C,D,S) is
begin
  if (S ="00") then
      Z <= A;
  elsif (S="01") then
      Z <= B;
  elsif (S ="10") then
      Z <= C;
  else
      Z <= D;
  end if;
 
end process;
end bhv;
