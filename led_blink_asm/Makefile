all: firmware.bin

main.o: main.s
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb main.s -o main.o

firmware.bin: main.o
	arm-none-eabi-objcopy -O binary main.o firmware.bin

clean:
	rm -f main.o firmware.bin