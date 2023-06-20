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


# EXEFILE = sepia
# OBJECTS = main.o sepia_x86.o
# CCFMT = -m32
# NASMFMT = -f elf32
# CCOPT =
# NASMOPT = -w+all

# .c.o:
# 	cc $(CCFMT) $(CCOPT) -c $<

# .s.o:
# 	nasm $(NASMFMT) $(NASMOPT) -l $*.lst $<

# $(EXEFILE): $(OBJECTS)
# 	cc $(CCFMT) -o $@ $^

# clean:
# 	rm *.o *.lst $(EXEFILE)


# EXEFILE = sepia
# OBJECTS = main.o sepia_x86.o
# CCFMT = -m32
# NASMFMT = -f elf32
# CCOPT =
# NASMOPT = -w+all

# .PHONY: all clean

# all: $(EXEFILE)

# $(EXEFILE): $(OBJECTS)
# 	cc $(CCFMT) -o $@ $^

# .c.o:
# 	cc $(CCFMT) $(CCOPT) -c $<

# .s.o:
# 	nasm $(NASMFMT) $(NASMOPT) -l $*.lst $<

# sepia_x86.o: sepia_x86.asm
# 	nasm $(NASMFMT) $(NASMOPT) -o $@ -l sepia_x86.lst $<

# clean:
# 	rm -f $(EXEFILE) $(OBJECTS) *.lst

