# rlwe
This project implments RLWE Homomorphic encryption on PYNQ FPGA using VHDL and verilog

The Specification of RLWE Homomorphic is 

   constant n  : integer := 2**4; = Degree of Polynomial
   
   constant q  : natural := 2**15; = width of coeffcient 
   
   constant t  : natural := 2**8; = plaintext modulus
