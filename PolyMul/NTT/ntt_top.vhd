----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dr. Rouab Paul
-- 
-- Create Date: 24.12.2022 11:08:07
-- Design Name: 
-- Module Name: ntt_top - Behavioral
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

use work.ntt_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ntt_top is
    Port ( clk  : in STD_LOGIC;
           A    : in A_type;
           rst  : in STD_LOGIC;
           Y    : out A_type;
           done : out std_logic           
           );
end ntt_top;

architecture Behavioral of ntt_top is
signal A_rev : A_type;
signal index : br_type;
signal shift : br_type;
type state_type is (idle, cal, condm,  finish);
signal state        : state_type;
signal m, j, k :integer range 0 to 2*n-1;
signal u, t :integer range 0 to 2*q;
signal w, wm :integer range 0 to 2*q;

begin

bit_reverse : for p in 0 to n-1 generate
  shift(p)<=std_logic_vector(to_unsigned(p, logn));
   bit_reverse_inner : for q in 0 to logn-1 generate
      index(p)(q)<=shift(p)(logn-1-q);
   end generate bit_reverse_inner;
   A_rev(p)<=A(to_integer(unsigned(index(p))));   
end generate bit_reverse;

addr_gen : process(clk, rst)--generate address
begin
if rising_edge(clk) then
    if(rst='1') then
     state<=idle;
    else
       case state is
             when idle =>  
              m<=2;
              j<=0;
              k<=0;
              state<=cal;
              wm<=w_init;
              w<=1;
             when cal=>
               --u<=to_integer(unsigned(A_rev(k+j))); --+ std_logic_vector(to_unsigned(w, logq))*A_rev((k+j+m/2)mod n))) mod w;
              --t<=to_integer(unsigned(A_rev(k+j))); -- - std_logic_vector(to_unsigned(w, logq))*A_rev((k+j+m/2) mod n))) mod w;
            ----------------------------------------
              A_rev(k+j)<=std_logic_vector(to_unsigned(to_integer(unsigned(A_rev(k+j) + std_logic_vector(to_unsigned(w, logq))*A_rev(k+j+m/2))) mod w, logq));
               A_rev(k+j+m/2)<=std_logic_vector(to_unsigned(to_integer(unsigned(A_rev(k+j) - std_logic_vector(to_unsigned(w, logq))*A_rev(k+j+m/2))) mod w, logq));
            ----------------------------------

  
             state<=condm;
             
              when condm=>
                 -----------------
                 if m>n then
                  state<=finish;
                 else    
                 ---------------              
                  if j=(m/2) then
                     m<=m*2;
                     j<=0;
                     k<=0;
                  else
                     ---------------               
                      if k=n-m then -- 0 to n-1                     
                         j<=j+1 ;
                         k<=0;
                      else                  
                         k<=k+m;
                      end if;
                     ------------------
                  end if;
                  ----------------------
                  state<=cal;
                 end if;
                 

                
              
              
               when finish=>
                state<=finish;
               
              
        
              
       end case;
     end if;
 end if;
 end process;

end Behavioral;
