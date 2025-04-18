#!/bin/bash
nasm -f elf32 fibonacci.asm -o fibonacci.o
ld -m elf_i386 fibonacci.o -o fibonacci
./fibonacci


# " chmod +x build.sh " ---> ( We will first run this in Terminal to make the build script executable )
            
# " ./build.sh " ---> ( Now we execute it with this build Script )