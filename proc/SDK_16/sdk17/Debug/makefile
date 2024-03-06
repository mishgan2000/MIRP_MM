################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/mrte/subdir.mk
-include src/can/subdir.mk
-include src/FreeRTOS/subdir.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
sdk17.elf.size \

ELFCHECK += \
sdk17.elf.elfcheck \


# All Target
all: sdk17.elf secondary-outputs

# Tool invocations
sdk17.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: MicroBlaze gcc linker'
	mb-gcc -Wl,-T -Wl,../src/lscript.ld -L../../sdk17_bsp/microblaze_0/lib -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v8.50.c -mno-xl-soft-mul -mhard-float -mxl-float-convert -mxl-float-sqrt -Wl,--no-relax -Wl,--gc-sections -o "sdk17.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

sdk17.elf.size: sdk17.elf
	@echo 'Invoking: MicroBlaze Print Size'
	mb-size sdk17.elf  |tee "sdk17.elf.size"
	@echo 'Finished building: $@'
	@echo ' '

sdk17.elf.elfcheck: sdk17.elf
	@echo 'Invoking: Xilinx ELF Check'
	elfcheck sdk17.elf -hw ../../proc_hw_platform/system.xml -pe microblaze_0  |tee "sdk17.elf.elfcheck"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(C_DEPS)$(EXECUTABLES)$(ELFSIZE)$(ELFCHECK)$(S_UPPER_DEPS) sdk17.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE) $(ELFCHECK)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
