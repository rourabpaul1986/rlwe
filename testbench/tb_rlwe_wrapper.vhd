----------------------------------------------------------------------------------
-- Company: Siksha O Anusandhan
-- Engineer: Dr. Rourab Paul
-- 
-- Create Date: 13.07.2022 11:10:45
-- Design Name: 
-- Module Name: tb_rlwe_wrapper - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_rlwe_wrapper is
--  Port ( );
end tb_rlwe_wrapper;

architecture Behavioral of tb_rlwe_wrapper is

component rlwe_top is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           enable : in STD_LOGIC;
           sample : out std_logic_vector(12 downto 0);
           done : out STD_LOGIC);
end component;
signal clk : STD_LOGIC;
signal rst : STD_LOGIC;
signal enable : STD_LOGIC;
signal sample :  std_logic_vector(12 downto 0);
signal done : STD_LOGIC;
 CONSTANT period : TIME := 10 ns;
begin

   test_uut : rlwe_top
   --    generic map (
-- C_M00_AXIS_TDATA_WIDTH    => C_M_AXIS_TDATA_WIDTH,
 --C_S00_AXIS_TDATA_WIDTH    =>C_S_AXIS_TDATA_WIDTH
--)
port map (
 clk =>clk,
 rst=>rst,
 enable =>enable,
 sample=>sample,
 done=>done
  ); 

            clk_master: process
            begin            
              clk <='0';
            wait for period/2;
              clk <='1';
            wait for period/2;
          end process;
          
           stim_prco: process
          begin
          rst<='1';
          enable <='0';
          wait for 10ns;
          ---------------------------
          rst<='0';
          enable <='1';
        
           wait;
          end process;
end Behavioral;
