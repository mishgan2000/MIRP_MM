################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/mrte/io-mrte.c 

OBJS += \
./src/mrte/io-mrte.o 

C_DEPS += \
./src/mrte/io-mrte.d 


# Each subdirectory must supply rules for building sources it contributes
src/mrte/%.o: ../src/mrte/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -I../../seven_bsp/microblaze_0/include -I"C:\Work\XILINX\Projects\New_25\proc\SDK_7\seven\src" -I"C:\Work\XILINX\Projects\New_25\proc\SDK_7\seven\src\can" -I"C:\Work\XILINX\Projects\New_25\proc\SDK_7\seven\src\FreeRTOS" -I"C:\Work\XILINX\Projects\New_25\proc\SDK_7\seven\src\mrte" -c -fmessage-length=0 -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v8.50.c -mno-xl-soft-mul -mhard-float -mxl-float-convert -mxl-float-sqrt -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


