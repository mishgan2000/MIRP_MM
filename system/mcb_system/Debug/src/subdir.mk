################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/can_cmd.c \
../src/crc.c \
../src/dd_mirp.c \
../src/fpga.c \
../src/leds.c \
../src/main.c \
../src/platform.c 

LD_SRCS += \
../src/lscript.ld 

OBJS += \
./src/can_cmd.o \
./src/crc.o \
./src/dd_mirp.o \
./src/fpga.o \
./src/leds.o \
./src/main.o \
./src/platform.o 

C_DEPS += \
./src/can_cmd.d \
./src/crc.d \
./src/dd_mirp.d \
./src/fpga.d \
./src/leds.d \
./src/main.d \
./src/platform.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -I../../mcb_system_bsp/microblaze_0/include -I"C:\Work\XILINX\Projects\New_25\system\mcb_system\src\can" -I"C:\Work\XILINX\Projects\New_25\system\mcb_system\src\FreeRTOS" -I"C:\Work\XILINX\Projects\New_25\system\mcb_system\src\mrte" -I"C:\Work\XILINX\Projects\New_25\system\mcb_system\src" -c -fmessage-length=0 -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v8.50.c -mno-xl-soft-mul -mhard-float -mxl-float-convert -mxl-float-sqrt -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


