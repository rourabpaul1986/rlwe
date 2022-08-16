----------------------------------------------------------------------------------
-- Company: Siksa O Anusandhan
-- Engineer: Dr. Rourab paul
-- 
-- Create Date: 22.07.2022 10:21:30
-- Design Name: 
-- Module Name: rlwe_top - rlwe_top_arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This is a wrapper of all subcomponents of RLWE
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
use ieee.numeric_std.all;
use work.rlwe_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rlwe_top is
    Port ( clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       enable : in STD_LOGIC;
       sample : out std_logic_vector(12 downto 0);
       done : out STD_LOGIC);
end rlwe_top;

architecture rlwe_top_arch of rlwe_top is

component rng_trivium_sk is

   generic(
        num_bits:   integer range 1 to 64;
        init_key:   std_logic_vector(79 downto 0);
        init_iv:    std_logic_vector(79 downto 0) 
         );
    port (
        clk:        in  std_logic;
        rst:        in  std_logic;
        reseed:     in  std_logic;
        newkey:     in  std_logic_vector(79 downto 0);
        newiv:      in  std_logic_vector(79 downto 0);
        out_ready:  in  std_logic;
        mem_ctrl:  out  std_logic_vector(1 downto 0);
        smux:  out  std_logic_vector(2 downto 0);
        addr:  out  std_logic_vector(7 downto 0);
        out_valid:  out std_logic;
        out_data:   out std_logic_vector(num_bits-1 downto 0) );

end component;
----------------------------------------------------------------
component mem_ctrl_mux is
    generic (
mux_dw:   integer range 1 to 64
);
 port(
     I0,I1,I2,I3,I4,I5,I6,I7 : in STD_LOGIC_vector(mux_dw-1 downto 0);
 S: in STD_LOGIC_vector(2 downto 0);
 O: out STD_LOGIC_vector(mux_dw-1 downto 0)
  );
end component;
----------------------------------------------------------------
component mem_ctrl_dmux is
    generic (
dmux_dw:   integer range 1 to 64
);
Port ( I : in  STD_LOGIC_VECTOR (dmux_dw-1 downto 0); 
       S : in STD_LOGIC_VECTOR (2 downto 0);
       Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7 : out STD_LOGIC_VECTOR (dmux_dw-1 downto 0));

end component;
----------------------------------------------------------------
component mem_rlwe is
port(
 clk  : in  std_logic;
 we   : in  std_logic;
 en   : in  std_logic;
 addr : in  std_logic_vector(7 downto 0);
 di   : in  std_logic_vector(logq-1 downto 0);
 do   : out std_logic_vector(logq-1 downto 0)

);
end component;
----------------------------------------------------------------
component poly_mul is
    generic (
base_addr_multiplicand:   natural range 0 to 255;
base_addr_multipyer:   natural range 0 to 255);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           mult_in: in std_logic_vector(logq-1 downto 0);
           mem_ctrl:  out  std_logic_vector(1 downto 0);
           sdmux :  out std_logic_vector(2 downto 0);
           addr :  out std_logic_vector(7 downto 0);
           mult_out: out mult_type;
           read_mem: out std_logic;
           done : out STD_LOGIC);
end component;
----------------------------------------------------------------
component poly_add is
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
end component;
------------------------------------------------------------------
----------------------------------------------------------------
component rng_trivium_a is

   generic(
        num_bits:   integer range 1 to 64;
        init_key:   std_logic_vector(79 downto 0);
        init_iv:    std_logic_vector(79 downto 0) 
         );
    port (
        clk:        in  std_logic;
        rst:        in  std_logic;
        reseed:     in  std_logic;
        newkey:     in  std_logic_vector(79 downto 0);
        newiv:      in  std_logic_vector(79 downto 0);
        out_ready:  in  std_logic;
        mem_ctrl:  out  std_logic_vector(1 downto 0);
        smux:  out  std_logic_vector(2 downto 0);
        addr:  out  std_logic_vector(7 downto 0);
        out_valid:  out std_logic;
        out_data:   out std_logic_vector(num_bits-1 downto 0) 
        );

end component;
----------------------------------------------------------------
 signal reseed        : std_logic:='0';
 signal newkey:   std_logic_vector(79 downto 0);
 signal newiv:  std_logic_vector(79 downto 0);
 signal sk_n:  std_logic_vector(logq-1 downto 0);
signal adder_op2:  std_logic_vector(logq-1 downto 0);
signal adder_out:  std_logic_vector(logq-1 downto 0);
 signal sk_1:  std_logic_vector(0 downto 0);
 signal zero:  std_logic_vector(logq-2 downto 0):=(others=>'0');
 -------------------------------------------------------------
 signal SMUX, SAddrMUX, smux_sk, smux_a:  std_logic_vector(2 downto 0);
 signal SDMUX, sdmux_mult,  sdmux_adder:  std_logic_vector(2 downto 0);
 signal DI2,DI3,DI4,DI5, DI6, DI7,  DY0, DY1,DY4,DY5, DY6, DY7,e, mult_in:  std_logic_vector(logq-1 downto 0);
 signal mux_out,dmux_in:  std_logic_vector(logq-1 downto 0);
 -------------------------------------------------
 signal we, mem_en, a_en:  std_logic;
 signal counter : integer range 0 to 255;
 signal do:  std_logic_vector(n-1 downto 0);
 signal addr :  std_logic_vector(7 downto 0);
 signal mult_out :  mult_type;
 signal a_pol :  std_logic_vector(logq-1 downto 0);
 signal sk_nAddr, a_Addr, CAddr, DAddr, mult_addr, add_addr,  AI4,AI5,AI6, AI7 :  std_logic_vector(7 downto 0);
 signal a_gen_done, sk_done, rst_a, rst_mul, read_mem_mul, div_done, invert_div_done         : std_logic:='0';
---------------memory control signals-----------------------------------------------------------
 signal sk_mem_ctrl, mul_mem_ctrl, a_mem_ctrl, c_mem_ctrl, add_mem_ctrl, mem_ctrl, MI4,MI5,MI6,MI7       : std_logic_vector(1 downto 0);
---------------------------------------------------------------------------
begin
--------------------------------------
rng_sk : rng_trivium_sk 
   generic map (
   num_bits=> 1,
   init_key=>init_key,
   init_iv=>init_iv
 )
port map (
 clk =>clk,
 rst=>rst,
 reseed=>reseed,
 newkey=>newkey,
 newiv=>newiv,
 out_ready=>enable,
 mem_ctrl=>sk_mem_ctrl,
 smux =>smux_sk,
 addr=>sk_nAddr,
 out_valid=>sk_done,
 out_data=>sk_1
 );
  sk_n<=zero & sk_1;
---------------------------------------------
SMUX<= smux_sk when sk_done='1' else
       smux_a  when a_gen_done='1' else
       sdmux_mult  when read_mem_mul='1'else
       sdmux_adder  when div_done='1';
SDMUX<=sdmux_mult  when read_mem_mul='1' else
       sdmux_adder  when div_done='1';

--------------------------------------
mux_cntrl : mem_ctrl_mux --data write---
   generic map (mux_dw=> logq)
port map ( I0=>sk_n, I1=>a_pol, I2=>DI2, I3=>DI3, I4=>adder_out, I5=>DI5, I6=>DI6, I7=>DI7, S=>SMUX, O=>mux_out );
---------------------------------------------
--------------------------------------
mux_addr_cntrl : mem_ctrl_mux --memory address
generic map (mux_dw=>8)
port map ( I0=>sk_nAddr, I1=>a_Addr, I2=>mult_addr, I3=>add_addr, I4=>add_addr, I5=>AI5, I6=>AI6, I7=>AI7, S=>SMUX, O=>addr );

--port map ( I0=>sk_nAddr, I1=>a_Addr, I2=>mult_addr, I3=>add_addr, I4=>AI4. I5=>AI5, I6=>AI6, I7=>AI7,S=>SMUX, O=>addr);
--smux=00; sk is written  in memory
--smux=01; a is written  in memory
--smux=10; poly mul read operands from   memory 
--smux=11; poly add read operands from   memory 
---------------------------------------------
--------------------------------------
mux_mem_cntrl : mem_ctrl_mux --memory control signal
generic map (mux_dw=>2)
port map ( I0=>sk_mem_ctrl, I1=>a_mem_ctrl, I2=>mul_mem_ctrl, I3=>add_mem_ctrl, I4=>add_mem_ctrl, I5=>MI5, I6=>MI6, I7=>MI7, S=>SMUX, O=>mem_ctrl );
--port map ( A=>sk_mem_ctrl, B=>a_mem_ctrl, C=>mul_mem_ctrl, D=>add_mem_ctrl, S=>SMUX, Z=>mem_ctrl );
---------------------------------------------
----------------------------------------
dmux_data : mem_ctrl_dmux --data read--
generic map (dmux_dw=>logq)
port map ( I =>dmux_in, S => SDMUX ,Y0=> DY0 ,Y1=> DY1, Y2=>mult_in,Y3=>e, Y4=>DY4, Y5=>DY5, Y6=>DY6, Y7=>DY7);
-----------------------------------------------
----------------------------------------
--dmux_addr : mem_ctrl_dmux --addr--
--generic map (dmux_dw=>8)
--port map ( I =>dmux_in, S => SDMUX ,Y1=> mult_in ,Y2=> Y2, Y3=>Y3,Y4=>Y4);
-----------------------------------------------
--------------------------------------
memory_rlwe : mem_rlwe 
port map (
 clk =>clk,
 we=>mem_ctrl(0), 
 en=>mem_ctrl(1),
 addr=>addr,
 di=>mux_out,
 do=>dmux_in
 );
---------------------------------------------
rng_a : rng_trivium_a 
    generic map (
    num_bits=> logq,
    init_key=>Ainit_key,
    init_iv=>Ainit_iv
  )
 port map (
  clk =>clk,
  rst=>rst,
  reseed=>reseed,
  newkey=>newkey,
  newiv=>newiv,
  out_ready=>enable,
  mem_ctrl=>a_mem_ctrl,
  smux=>smux_a,
  addr=>a_addr,
  out_valid=>a_gen_done,
  out_data=>a_pol
  );   

-----------------------------------------------
rst_mul<='0' when counter>base_addr_e2+n-1 else '1';
-----------------------------------------------
poly_multiplication: poly_mul
    generic map (
base_addr_multiplicand=>base_addr_a,
base_addr_multipyer=>base_addr_sk
)
 port map (
  clk =>clk,
  rst=>rst_mul,
  mult_in=>mult_in,
  mem_ctrl=>mul_mem_ctrl,
  sdmux=>sdmux_mult,
  addr=>mult_addr,
  mult_out=>mult_out,
  read_mem=>read_mem_mul,
  done=>div_done
  );   
  
  invert_div_done<= not div_done;
 -----------------------------------------------
 poly_addition: poly_add
     generic map (
     rd_base_addr=> base_addr_e,
     wr_base_addr=> base_addr_b
   )
  port map (
         clk =>clk,
         rst => invert_div_done,
         adder_op1=>mult_out,
         adder_op2=>e,
         sdmux=>sdmux_adder,
         mem_ctrl=>add_mem_ctrl,
         addr =>add_addr,
         adder_out =>adder_out,
         done =>done
         );
--------------------------------------------------
process(clk)
begin
if rising_edge(clk) then
    if(rst='1') then
      --  rst_mul<='1';
        counter<=0;
    elsif(sk_done='1') then
     counter<=counter+1;
    elsif(a_gen_done='1') then
     counter<=counter+1;
    else
    
    end if;
end if;
end process;


end rlwe_top_arch;
