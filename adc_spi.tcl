set_location_assignment	PIN_M1	-to rst_n
set_location_assignment	PIN_E1	-to sys_clk
#SPI
set_location_assignment	PIN_T4 -to I_spi_cs
set_location_assignment	PIN_R3 -to O_spi_miso
set_location_assignment	PIN_T3 -to I_spi_sck
set_location_assignment	PIN_P3 -to I_spi_mosi

#SPI2
set_location_assignment	PIN_T9 -to spi_cs
set_location_assignment	PIN_T8 -to spi_miso
set_location_assignment	PIN_T7 -to spi_sck
set_location_assignment	PIN_R8 -to spi_mosi


#ADC_CLK
set_location_assignment	PIN_D6	-to clk_drive
#ADC_IO
set_location_assignment	PIN_C6	-to ADC_IO[0]
set_location_assignment	PIN_E6	-to ADC_IO[1]
set_location_assignment	PIN_D5	-to ADC_IO[2]
set_location_assignment	PIN_D4	-to ADC_IO[3]
set_location_assignment	PIN_C3	-to ADC_IO[4]
set_location_assignment	PIN_B13	-to ADC_IO[5]
set_location_assignment	PIN_A13	-to ADC_IO[6]
set_location_assignment	PIN_B12	-to ADC_IO[7]
set_location_assignment	PIN_A12	-to ADC_IO[8]
set_location_assignment	PIN_B11	-to ADC_IO[9]
set_location_assignment	PIN_A11	-to ADC_IO[10]
set_location_assignment	PIN_B10	-to ADC_IO[11]
set_location_assignment	PIN_A10	-to ADC_IO[12]
set_location_assignment	PIN_B9	-to GND1
set_location_assignment	PIN_A9	-to GND2

#DAC_IO
set_location_assignment	PIN_K5	-to da_data[0]
set_location_assignment	PIN_L8	-to da_data[1]
set_location_assignment	PIN_J6	-to da_data[2]
set_location_assignment	PIN_K8	-to da_data[3]
set_location_assignment	PIN_F7	-to da_data[4]
set_location_assignment	PIN_G5	-to da_data[5]
set_location_assignment	PIN_F5	-to da_data[6]
set_location_assignment	PIN_F6	-to da_data[7]
set_location_assignment	PIN_E5	-to da_data[8]
set_location_assignment	PIN_C8	-to da_data[9]
set_location_assignment	PIN_D3	-to da_data[10]
set_location_assignment	PIN_E7	-to da_data[11]
set_location_assignment	PIN_D8	-to da_data[12]
set_location_assignment	PIN_E8	-to da_data[13]
set_location_assignment	PIN_E9	-to da_clk

#DAC_IO
#set_location_assignment	PIN_N3	-to da_data[0]
#set_location_assignment	PIN_M6	-to da_data[1]
#set_location_assignment	PIN_R1	-to da_data[2]
#set_location_assignment	PIN_T2	-to da_data[3]
#set_location_assignment	PIN_P1	-to da_data[4]
#set_location_assignment	PIN_P2	-to da_data[5]
#set_location_assignment	PIN_N1	-to da_data[6]
#set_location_assignment	PIN_N2	-to da_data[7]
#set_location_assignment	PIN_L1	-to da_data[8]
#set_location_assignment	PIN_L2	-to da_data[9]
#set_location_assignment	PIN_L4	-to da_data[10]
#set_location_assignment	PIN_L6	-to da_data[11]
#set_location_assignment	PIN_L7	-to da_data[12]
#set_location_assignment	PIN_L3	-to da_data[13]
#set_location_assignment	PIN_K6	-to da_clk