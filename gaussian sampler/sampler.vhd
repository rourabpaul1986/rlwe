----------------------------------------------------------------------------------
-- Company: SOA
-- Engineer: Dr. Rourab Paul
-- 
-- Create Date: 20.10.2022 15:20:33
-- Design Name: 
-- Module Name: sampler_ctrl - sampler_ctrl_arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Pre Gnerated gaussian Sample (mean-0 and dstandard daviation-10)
-- is stored gaussian_sampler(ROM). Randomely sample values are read by changing offset value
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.rlwe_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sampler_ctrl is
    Port ( addr   : in STD_LOGIC_vector(logn-1 downto 0);
           offset : in STD_LOGIC_vector(logn-1 downto 0);
           data   : out STD_LOGIC_vector(logq-1 downto 0));
end sampler_ctrl;

architecture sampler_ctrl_arch of sampler_ctrl is
component gaussian_sampler is
    Port ( a   : in  STD_LOGIC_vector(2*logn-1 downto 0);
           spo : out STD_LOGIC_vector(logq-1 downto 0));
end component;
signal a  :  STD_LOGIC_vector(2*logn-1 downto 0);
begin
a<=addr+offset*std_logic_vector(to_unsigned(n, logn));
 design_gm: gaussian_sampler
 port map (a   => a,
           spo => data
        );
end sampler_ctrl_arch;

