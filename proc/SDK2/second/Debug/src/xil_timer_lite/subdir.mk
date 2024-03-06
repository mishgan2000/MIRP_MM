################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/xil_timer_lite/my_xil_timer.c 

OBJS += \
./src/xil_timer_lite/my_xil_timer.o 

C_DEPS += \
./src/xil_timer_lite/my_xil_timer.d 


# Each subdirectory must supply rules for building sources it contributes
src/xil_timer_lite/%.o: ../src/xil_timer_lite/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -I../../second_bsp/microblaze_0/include -I"C:\Work\XILINX\Projects\New_25\proc\SDK2\second\src\FreeRTOS" -I"C:\Work\XILINX\Projects\New_25\proc\SDK2\second\src" -I"C:\Work\XILINX\Projects\New_25\proc\SDK2\second\src\xil_timer_lite" -c -fmessage-length=0 -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v8.50.c -mno-xl-soft-mul -mhard-float -mxl-float-convert -mxl-float-sqrt -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


