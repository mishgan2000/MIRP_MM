################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/FreeRTOS/FreeRTOS_mb_hooks.c \
../src/FreeRTOS/croutine.c \
../src/FreeRTOS/event_groups.c \
../src/FreeRTOS/heap_1.c \
../src/FreeRTOS/list.c \
../src/FreeRTOS/port.c \
../src/FreeRTOS/port_exceptions.c \
../src/FreeRTOS/queue.c \
../src/FreeRTOS/stream_buffer.c \
../src/FreeRTOS/tasks.c \
../src/FreeRTOS/timers.c 

S_UPPER_SRCS += \
../src/FreeRTOS/portasm.S 

OBJS += \
./src/FreeRTOS/FreeRTOS_mb_hooks.o \
./src/FreeRTOS/croutine.o \
./src/FreeRTOS/event_groups.o \
./src/FreeRTOS/heap_1.o \
./src/FreeRTOS/list.o \
./src/FreeRTOS/port.o \
./src/FreeRTOS/port_exceptions.o \
./src/FreeRTOS/portasm.o \
./src/FreeRTOS/queue.o \
./src/FreeRTOS/stream_buffer.o \
./src/FreeRTOS/tasks.o \
./src/FreeRTOS/timers.o 

C_DEPS += \
./src/FreeRTOS/FreeRTOS_mb_hooks.d \
./src/FreeRTOS/croutine.d \
./src/FreeRTOS/event_groups.d \
./src/FreeRTOS/heap_1.d \
./src/FreeRTOS/list.d \
./src/FreeRTOS/port.d \
./src/FreeRTOS/port_exceptions.d \
./src/FreeRTOS/queue.d \
./src/FreeRTOS/stream_buffer.d \
./src/FreeRTOS/tasks.d \
./src/FreeRTOS/timers.d 

S_UPPER_DEPS += \
./src/FreeRTOS/portasm.d 


# Each subdirectory must supply rules for building sources it contributes
src/FreeRTOS/%.o: ../src/FreeRTOS/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -I../../second_bsp/microblaze_0/include -I"C:\Work\XILINX\Projects\New_25\proc\SDK2\second\src\FreeRTOS" -I"C:\Work\XILINX\Projects\New_25\proc\SDK2\second\src" -I"C:\Work\XILINX\Projects\New_25\proc\SDK2\second\src\xil_timer_lite" -c -fmessage-length=0 -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v8.50.c -mno-xl-soft-mul -mhard-float -mxl-float-convert -mxl-float-sqrt -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/FreeRTOS/%.o: ../src/FreeRTOS/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -I../../second_bsp/microblaze_0/include -I"C:\Work\XILINX\Projects\New_25\proc\SDK2\second\src\FreeRTOS" -I"C:\Work\XILINX\Projects\New_25\proc\SDK2\second\src" -I"C:\Work\XILINX\Projects\New_25\proc\SDK2\second\src\xil_timer_lite" -c -fmessage-length=0 -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v8.50.c -mno-xl-soft-mul -mhard-float -mxl-float-convert -mxl-float-sqrt -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


