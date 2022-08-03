----------------------------------------------------------------------------------
-- Company: Siksa O Anusandhan
-- Engineer: Dr. Rourab Paul
-- 
-- Create Date: 22.07.2022 13:57:04
-- Design Name: 
-- Module Name: poly_mul - Behavioral
-- Project Name: 
-- Target Devices: PYNQ
-- Tool Versions: 
-- Description: 
-- This code is identical with PolyMul, becasue PolyDiv is a part of PolyMul for current version of code. The dividend is poly_mod here. The divisor is P 
--which is the multiplied value 
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

entity poly_mul is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           mult_in: in std_logic_vector(n-1 downto 0);
           mem_ctrl:  out  std_logic_vector(1 downto 0);
           sdmux :  out std_logic_vector(1 downto 0);
           addr :  out std_logic_vector(7 downto 0);
           mult_out: out std_logic_vector(n-1 downto 0);
           read_mem: out std_logic;
           done : out STD_LOGIC);
end poly_mul;

architecture Behavioral of poly_mul is
signal a,b:  std_logic_vector(n-1 downto 0);
signal zero_poly_mod:  std_logic_vector(logq-2 downto 0);
signal padded_poly_mod:  std_logic_vector(logq-1 downto 0);
signal product : p_type;
signal mul_start, read_mem_reg, mult_done :  std_logic;
signal addr_reg :  std_logic_vector(7 downto 0);
signal p :  p_type;--elements in higher index of th p is lower degree of the polynomial 
signal p_trun, p_trun_reg :  p_trun_type;
signal poly_mod_reg : p_trun_type;
signal muldiv:  std_logic_vector(logq-1 downto 0);

 signal i,j, counter, x, y, u, v : integer range 0 to 2*n;
type STATE_TYPE is (inrN, inr1, finish);
signal state        : STATE_TYPE;
type time_type is (Idle, sum_cal,finishmul);
signal timer       : time_type;
type div_state_type is (Idle, mult, update, divfin);
signal div_state       : div_state_type;
signal poly_mod:    std_logic_vector(2*n-3 downto 0):= zero_n_4 & '1' & zero_n_2 & '1';
begin
addr<=addr_reg;
read_mem<=read_mem_reg;
addr_gen : process(clk, rst)--generate address
begin
if rising_edge(clk) then
    if(rst='1') then
     addr_reg<=(others=>'0');
     i<=base_addr_sk; j<=base_addr_a;
     state<=inrN;
     read_mem_reg<='0';
     sdmux<="00";
     mem_ctrl<="00";
    else
       case state is
             when inrN =>  
              mem_ctrl<="10";
              sdmux<="10";
              read_mem_reg<='1';            
               addr_reg<=std_logic_vector(to_unsigned(i, 8));  
               state<=inr1;    
             when inr1 =>
              addr_reg<=std_logic_vector(to_unsigned(j, 8));
              --if(j=2*n-1) then
              if(j=base_addr_a+n-1) then
               j<=base_addr_a;
               i<=i+1;
               if(i=base_addr_sk+n-1) then
                state<=finish;
               else
                state<=inrN;
               end if;
              else 
               j<=j+1;
               state<=inr1;
              end if; 
             when finish=>
              mem_ctrl<="00";
              read_mem_reg<='0';
              state<=finish;            
       end case;
    end if;
end if;
end process;

process(clk)--delay of one clock
begin
if rising_edge(clk) then
    if(rst='1') then
    mul_start<='0';
    elsif (read_mem_reg='1') then
      mul_start<='1';
    elsif(read_mem_reg='0') then
      mul_start<='0';
    end if;
end if;
end process;
-------------------------------------------------
process(clk)--a stroing processs
begin
if rising_edge(clk) then
    if(rst='1') then
    counter<=0;
    elsif(mul_start='1') then
        if(counter=n) then
            counter<=0;
            a<=mult_in;
        elsif(counter=0) then 
            a<=mult_in;
            counter<=counter+1;    
        else
          counter<=counter+1;    
        end if; 
    end if;
end if;
end process;
--------------------------------------
process(clk)--polynomial multiplication
begin
if rising_edge(clk) then
    if(rst='1') then
    timer<=Idle;
    mult_done<='0';
    p<=(others=>(others=>'0'));
    x<=0; y<=0;
    elsif(mul_start='1') then
     case timer is
      when Idle =>                
       timer<=sum_cal;
      when sum_cal =>  
         p(x+y)<=p(x+y)+a*mult_in;
        if(y=n-1) then
            x<=x+1;
            y<=0;
            if(x=n-1) then
              timer<=finishmul;
              mult_done<='1';
            else
                timer<=Idle;
            end if;
        else
            y<=y+1;
           -- timer<=sum_cal;
       end if;
       
      when finishmul=>
        mult_done<='1';
        timer<=finishmul;  
     end case;
    end if;
end if;
end process;
--------------------------------------
  truncate_loop : for I in 0 to 2*n-3 generate
   p_trun(I)<='0'& p(I)(logq-1 downto 0);
   end generate  truncate_loop;
----------------------------------------
----------------------------------------
--  truncate_final_loop : for I in 0 to 2*n-3 generate
--   p_trun_reg(I)<='0' & p_trun(I)(logq-1 downto 0);
--   end generate  truncate_final_loop;
------------------------------------------
----------------------------------------
process(clk, u ,v)--polynomial division
begin
if rising_edge(clk) then
    if(rst='1') then
     div_state<=idle;
     u<=0;v<=0;
    elsif(mult_done='1') then
     case div_state is
     
       when idle=>
         p_trun_reg<=p_trun;
         div_state<=mult;
         poly_mod_reg<=(others=>(others=>'0'));
         
       when mult=>
--          if(poly_mod(v)='1') then
--            poly_mod_reg(v)<=p_trun_reg(u);
--          end if;
            muldiv<=p_trun_reg(u)(logq-1 downto 0);
            div_state<=update;
          
       when update=>      

        if(poly_mod(v)='1') then
         -- if(p_trun_reg(v)(logq-1 downto 0)>=muldiv) then --positive and zero
            p_trun_reg(v)(logq-1 downto 0)<= p_trun_reg(v)(logq-1 downto 0) -  muldiv;
            p_trun_reg(v)(logq)<='0';
          --elsif(p_trun_reg(v)(logq-1 downto 0)<muldiv) then --negative 
            --p_trun_reg(v)(logq-1 downto 0)<=muldiv- p_trun_reg(v)(logq-1 downto 0);
            --p_trun_reg(v)(logq)<='0';
         -- end if;
        end if;
         
         if(v=2*n-3) then
            u<=u+1;
            v<=u+1;
            if(u=n-3) then
                div_state<=divfin;
            else
                div_state<=mult;
                poly_mod<=poly_mod(2*n-4 downto 0) & '0';
            end if;
         else
          v<=v+1;
          div_state<=update;
         end  if;
         
        when divfin=>
          div_state<=divfin;
         
     end case;
    end if;
end if;
end process;
   
end Behavioral;
