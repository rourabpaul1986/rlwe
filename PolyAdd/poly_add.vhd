----------------------------------------------------------------------------------
-- Company: Soa
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
  rd_base_addr:     natural;
  wr_base_addr:     natural
   );
    Port ( clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       adder_op1: in  mult_type;
       adder_op2: in  std_logic_vector(logq-1 downto 0);
       sdmux :  out std_logic_vector(2 downto 0);
       mem_ctrl:  out  std_logic_vector(1 downto 0);
       addr :  out std_logic_vector(7 downto 0);
       adder_out: out  std_logic_vector(logq-1 downto 0);
       done : out STD_LOGIC);
end poly_add;

architecture Behavioral of poly_add is
signal addr_reg :  std_logic_vector(7 downto 0);
signal add_done :  std_logic;
signal op1, op2:   std_logic_vector(logq-1 downto 0);
signal adder_out_reg:  mult_type;
type add_state_type is (init, read, add, wrmem, addfin);
signal add_state       : add_state_type;
begin
addr<=addr_reg;
addition_gen : process(clk, rst)--generate address
begin
if rising_edge(clk) then
    if(rst='1') then
     addr_reg<=std_logic_vector(to_unsigned(rd_base_addr, 8));
     sdmux<="000";
     add_state<=init;
    else
     case add_state is
            when init =>  
              mem_ctrl<="10";
              sdmux<="011";
              adder_out_reg<=(others=>(others=>'0'));
              add_done<='0';
              add_state<=read;
            when read =>  
              
              add_state<=add;
            when add =>    
              --op1<=adder_op1(to_integer(unsigned(not addr_reg(logn-1 downto 0) ))mod n); 
              --adder_out<=adder_op1(to_integer(unsigned(not addr_reg(3 downto 0)))mod n)+adder_op2;
              adder_out_reg(to_integer(unsigned(addr_reg(logn-1 downto 0) )))<=adder_op1(to_integer(unsigned(not addr_reg(logn-1 downto 0))))+adder_op2;
              if(addr_reg=base_addr_e+n-1) then
                add_state<=wrmem;
                addr_reg<=std_logic_vector(to_unsigned(wr_base_addr, 8));
              else
               addr_reg<=addr_reg+1;
               add_state<=read;
              end if;
             when wrmem =>  
                adder_out<=adder_out_reg(to_integer(unsigned(addr_reg(logn-1 downto 0) )));
                mem_ctrl<="11";
                sdmux<="100";
               if(addr_reg=base_addr_b+n-1) then
                    add_state<=addfin;
               else
                    addr_reg<=addr_reg+1;
                    add_state<=wrmem;
                end if;
               when addfin =>  
                  add_done<='1';
                  add_state<=addfin;
           end case;
    end if;
end if;
end process;

done<=add_done;

end Behavioral;
