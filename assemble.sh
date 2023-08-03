#! /bin/bash

file=$1
mode=$2

if [ $mode -eq 32 ] 
then
    echo "[+] Compiling $file for $mode architecture"
    nasm -f elf32 $file.asm -o $file.o
    ld -m elf_i386 $file.o -o $file
    echo "[+] Done compiling"
    rm $file.o
elif [ $mode -eq 64 ]
then
    echo "[+] Compiling $file for $mode architecture"
    nasm -f elf64 $file.asm -o $file.o
    ld  $file.o -o $file
    echo "[+] Done compiling"
    rm $file.o
else
    echo specify the cpu architecture
fi