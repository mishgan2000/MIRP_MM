################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/can/can_config.c \
../src/can/can_freertos.c \
../src/can/can_opc.c 

OBJS += \
./src/can/can_config.o \
./src/can/can_freertos.o \
./src/can/can_opc.o 

C_DEPS += \
./src/can/can_config.d \
./src/can/can_freertos.d \
./src/can/can_opc.d 


# Each subdirectory must supply rules for building sources it contributes
src/can/%.o: ../src/can/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -I../../test_pr_bsp/microblaze_0/include -I"C:\Work\XILINX\Projects\New_25\proc\SDK_15\test_pr\src" -I"C:\Work\XILINX\Projects\New_25\proc\SDK_15\test_pr\src\can" -I"C:\Work\XILINX\Projects\New_25\proc\SDK_15\test_pr\src\FreeRTOS" -I"C:\Work\XILINX\Projects\New_25\proc\SDK_15\test_pr\src\mrte" -c -fmessage-length=0 -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v8.50.c -mno-xl-soft-mul -mhard-float -mxl-float-convert -mxl-float-sqrt -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


