library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;
package ntt_pkg is

   constant n  : integer := 2**3; --degree n-1
   constant q  : natural := 673;--prime
   constant t  : natural := 2**8;
   constant w_init  : natural  := 326;


   constant logq : positive := positive(ceil(log2(real(q))));
   constant logn : positive := positive(ceil(log2(real(n))));
   constant logt : positive := positive(ceil(log2(real(t))));
   constant delta  : natural := logq-logt;

   

   
   type A_type is array (0 to (n-1)) of std_logic_vector(logq-1 downto 0);
   type br_type is array (0 to (n-1)) of std_logic_vector(logn-1 downto 0);




end ntt_pkg; 
