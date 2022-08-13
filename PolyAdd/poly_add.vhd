----------------------------------------------------------------------------------
-- Company: SOA
-- Engineer: Dr. Rourab Paul
-- 
-- Create Date: 12.08.2022 17:19:43
-- Design Name: 
-- Module Name: poly_add - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.rlwe_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity poly_add is
   generic(
  base_addr:     natural
   );
    Port ( clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       adder_op1: in  mult_type;
       adder_op2: in  std_logic_vector(logq-1 downto 0);
       sdmux :  out std_logic_vector(1 downto 0);
       mem_ctrl:  out  std_logic_vector(1 downto 0);
       addr :  out std_logic_vector(7 downto 0);
       adder_out: out  std_logic_vector(logq-1 downto 0);
       done : out STD_LOGIC);
end poly_add;

architecture Behavioral of poly_add is
signal addr_reg :  std_logic_vector(7 downto 0);
signal op1, op2:   std_logic_vector(logq-1 downto 0);
type add_state_type is (Idle, mult, update, divfin);
signal add_state       : add_state_type;
begin
addr<=addr_reg;
addr_gen : process(clk, rst)--generate address
begin
if rising_edge(clk) then
    if(rst='1') then
     addr_reg<=std_logic_vector(to_unsigned(base_addr-1, 8));
     sdmux<="00";
    else
     mem_ctrl<="10";
     sdmux<="11";
     if(addr_reg=base_addr+n) then
     else
       op1<=adder_op1(to_integer(unsigned(addr_reg))mod n);
       adder_out<=adder_op1(to_integer(unsigned(addr_reg)) mod n)+adder_op2;
       addr_reg<=addr_reg+1;
     end if;
    end if;
end if;
end process;

end Behavioral;
