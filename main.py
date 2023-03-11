#https://discuss.pynq.io/t/tutorial-pynq-dma-part-2-using-the-dma-from-pynq/3134
import time
from pynq import Overlay


#num = input ("Enter number :")
#print(num)
ol = Overlay("./design_1_wrapper.bit")
dma = ol.axi_dma_0
dma_send = ol.axi_dma_0.sendchannel
dma_recv = ol.axi_dma_0.recvchannel

from pynq import allocate
import numpy as np

input_data_size = 17
output_data_size = 32
input_buffer = allocate(shape=(input_data_size,), dtype=np.uint32)

for i in range(input_data_size):
    input_buffer[i] = i
#input_buffer[16] = 74
################################################
# 0x40000000 for Key Gen + Encryption          #
# 0x00000000 for Key Gen                       #
# input_buffer[0] is the control word for rlwe #
################################################
input_buffer[0] = 0x40000000  
for i in range(1, input_data_size):
    print(input_buffer[i])
print("-----------------------")  
dma_send.transfer(input_buffer)

output_buffer = allocate(shape=(output_data_size,), dtype=np.uint32)

#for i in range(data_size):
#    print('0x' + format(output_buffer[i]))
print("-----------------------")    
dma_recv.transfer(output_buffer)
for i in range(output_data_size):
   
    print(i, format(output_buffer[i]))
