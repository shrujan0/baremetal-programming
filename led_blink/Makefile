TARGET  := firmware

CC      := arm-none-eabi-gcc
OBJCOPY := arm-none-eabi-objcopy
SIZE    := arm-none-eabi-size

C_SOURCES   := main.c
ASM_SOURCES := startup.s
LDSCRIPT    := stm32_linker_script.ld

MCUFLAGS := -mcpu=cortex-m4 -mthumb
CFLAGS   := $(MCUFLAGS) -std=c11 -O0 -g3 -ffreestanding -fdata-sections -ffunction-sections -Wall -Wextra
ASFLAGS  := $(MCUFLAGS) -g3
LDFLAGS  := $(MCUFLAGS) -T$(LDSCRIPT) -nostartfiles -Wl,--gc-sections -Wl,-Map=$(TARGET).map

C_OBJS   := $(C_SOURCES:.c=.o)
ASM_OBJS := $(ASM_SOURCES:.s=.o)
OBJS     := $(C_OBJS) $(ASM_OBJS)

ELF := $(TARGET).elf
BIN := $(TARGET).bin
HEX := $(TARGET).hex

all: $(ELF) $(BIN) $(HEX)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(CC) $(ASFLAGS) -c $< -o $@

$(ELF): $(OBJS) $(LDSCRIPT)
	$(CC) $(OBJS) $(LDFLAGS) -o $@
	$(SIZE) $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

clean:
	rm -f $(OBJS) $(ELF) $(BIN) $(HEX) $(TARGET).map

.PHONY: all clean