CFLAGS = -std=c11 -Wall -Wextra -pedantic -Werror -O3
SOURCES = main.c sepia.c bmp.c

x86: sepia_x86.asm $(SOURCES)
	nasm -f elf32 sepia_x86.asm
	$(CC) -m32 $(CFLAGS) $(SOURCES) sepia_x86.o -o sepia_x86.out

x64: sepia_x64.asm $(SOURCES)
	nasm -f elf64 sepia_x64.asm
	$(CC) -m64 $(CFLAGS) $(SOURCES) sepia_x64.o -o sepia_x64.out 

clean:
	rm *.o *.out
