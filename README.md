## A simple implement of data transmission between FPGA and STM32 via SPI
## 基于SPI协议的FPGA与STM32数据传输实践

本设计在ep4ce10平台下实现了高速率的FPGA与单片机SPI数据传输。在本设计中FPGA作为从机向STM32传输数据。
同时本设计还实现了由STM32向FPGA发送指令。在此基础上本设计实现了ADC芯片采样后数据经由FPGA发送至STM32，同时STM32可以通过指令的方式更改FPGA下的DAC输出的波形

目前代码缺少注释，感兴趣的可以结合以下博文理解：
https://doosam.uk/articles/spi-comm-stm32-fpga/
