################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
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
bidir.elf.size \

ELFCHECK += \
bidir.elf.elfcheck \


# All Target
all: bidir.elf secondary-outputs

# Tool invocations
bidir.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: MicroBlaze gcc linker'
	mb-gcc -Wl,-T -Wl,../src/lscript.ld -L../../bidir_bsp/microblaze_0/lib -mlittle-endian -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v8.50.c -mno-xl-soft-mul -mhard-float -mxl-float-convert -mxl-float-sqrt -Wl,--no-relax -Wl,--gc-sections -o "bidir.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

bidir.elf.size: bidir.elf
	@echo 'Invoking: MicroBlaze Print Size'
	mb-size bidir.elf  |tee "bidir.elf.size"
	@echo 'Finished building: $@'
	@echo ' '

bidir.elf.elfcheck: bidir.elf
	@echo 'Invoking: Xilinx ELF Check'
	elfcheck bidir.elf -hw ../../proc_hw_platform/system.xml -pe microblaze_0  |tee "bidir.elf.elfcheck"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(OBJS)$(C_DEPS)$(EXECUTABLES)$(ELFSIZE)$(ELFCHECK)$(S_UPPER_DEPS) bidir.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE) $(ELFCHECK)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
