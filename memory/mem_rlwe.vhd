----------------------------------------------------------------------------------
-- Company: Siksa O Anusandhan
-- Engineer: Dr. Rourab Paul
-- 
-- Create Date: 22.07.2022 13:57:04
-- Design Name: 
-- Module Name: mem_rlwe. - Behavioral
-- Project Name: 
-- Target Devices: PYNQ
-- Tool Versions: 
-- Description: 
-- This block stores messege, key, random number required for RLWE
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.rlwe_pkg.all; 

entity mem_rlwe is

port(

 clk  : in  std_logic;
 we   : in  std_logic;
 en   : in  std_logic;
 addr : in  std_logic_vector(7 downto 0);
 di   : in  std_logic_vector(n-1 downto 0);
 do   : out std_logic_vector(n-1 downto 0)

);

end mem_rlwe;

 

 architecture syn of mem_rlwe is

type ram_type is array (255 downto 0) of std_logic_vector(n-1 downto 0);

signal RAM : ram_type;

begin

process(clk)

begin

 if rising_edge(clk) then

   if en = '1' then

    if we = '1' then

     RAM(to_integer(unsigned(addr-1))) <= di;

    end if;

    do <= RAM(to_integer(unsigned(addr)));

  end if;

 end if;

end process;

 

end syn;

 

 
