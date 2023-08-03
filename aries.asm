section .data
    entryMessage db 0x0a, 'Hello, Welcome to Aries Parking Lobby. ', 0x0a, 'Select What you want to do', 0x0a ,'1. Park', 0x0a, '2. Retrieve', 0x0a, '3. Exit', 0x0a, "Select a Command: "
    lenEntryMessage equ $ - entryMessage    

    spotAvailMessage db 0x0a,'We have space available, Your parking spot ID is: '
    lenSpotAvailMessage equ $-spotAvailMessage

    chargeMessage db 0x0a, 'The charge for parking is Ghc4 per hour', 0x0a, '1 hour equivalent to 1 second for this program', 0x0a
    lenChargeMessage equ $-chargeMessage

    noSpotMessage db 0x0a, "Sorry but all spots are occupied", 0x0a
    lenNoSpotMessage equ $-noSpotMessage

    retrievalMessage db "Enter your parking spot ID: "
    lenRetrievalMessage equ $-retrievalMessage

    noCarMessage db 0x0a, "Sorry, There is no vehicle Available in Spot provided", 0x0a
    lenNoCarMessage equ $-noCarMessage

    carAvailMessage db "We will get your vehicle for you right way", 0x0a
    lenCarAvailMessage equ $-carAvailMessage

    retrieveCharge db "Your charge comes to GHc"
    lenRetrieveCharge equ $-retrieveCharge

    inValidMessage db 0x0a, "Invalid Command"
    lenInvalidMessage equ $-inValidMessage

    parking_spots times 10 db 0
    parking_time times 10 dd 0

section .bss
    commandNumber resb 3                   
    park_spot resb 3
    retrievalID resb 1
    stars resb 50
    charge resb 16
    lenCharge resw 1

section .text
    global _start


_start:

initialize_stars:
    mov byte[stars], 0x0a
    mov byte[stars + 49], 0x0a
    mov ecx, 1

fill_stars_loop:
    mov byte[stars + ecx], '*'
    cmp ecx, 48
    je program_entry

    inc ecx
    jmp fill_stars_loop

program_entry:


    call _printStars

    ; Print Entry Message
    push lenEntryMessage
    mov ecx, entryMessage
    call _print

    ;Take command input
    mov eax, 3                         
    mov ebx, 0           
    mov ecx, commandNumber             
    mov edx, 3        
    int 0x80                           
    call _printStars

    movzx ebx, byte[commandNumber]
    sub ebx, '0'

check_command:
    cmp ebx, 1
    je check_avail_spot

    cmp ebx, 2
    je retrieve

    cmp ebx, 3
    je exit

    mov eax, 4
    mov ebx, 1
    mov ecx, inValidMessage
    mov edx, lenInvalidMessage
    int 0x80

    jmp program_entry


check_avail_spot:
    mov ecx, 10
    mov esi, parking_spots
    xor ebx, ebx

find_spot:
    cmp byte[esi], 0
    je spot_avail

    inc ebx
    inc esi

    loop find_spot
    jmp no_spot

spot_avail:
    mov byte[parking_spots + ebx], 1
    mov edx, ebx

    ;set timer
    mov ecx, ebx
    call _getTime
    mov dword[parking_time + ecx * 4], eax

    ; convert spot number to char
    add edx, '0'
    mov byte[park_spot], dl

    ;print messages
    call _printStars

    push lenSpotAvailMessage
    mov ecx, spotAvailMessage
    call _print

    mov eax, 1
    push eax
    mov ecx, park_spot
    call _print
    
    push lenChargeMessage
    mov ecx, chargeMessage
    call _print


    call _printStars

    jmp program_entry

no_spot:
    call _printStars

    push lenNoSpotMessage
    mov ecx, noSpotMessage
    call _print

    call _printStars


    jmp program_entry


retrieve:
    call _printStars

    push lenRetrievalMessage
    mov ecx, retrievalMessage
    call _print

    mov eax, 3
    mov ebx, 0
    mov ecx, retrievalID
    mov edx, 3
    int 0x80

    call _printStars

    movzx eax, byte[retrievalID]
    sub eax, '0'
    cmp byte[parking_spots + eax], 1
    je car_avail

    mov eax, 4
    mov ebx, 1
    mov ecx, noCarMessage
    mov edx, lenNoCarMessage
    int 0x80

    jmp program_entry

car_avail:
    mov byte[parking_spots + eax], 0
    mov edx, dword[parking_time + eax * 4]
    
    mov dword[parking_time + eax * 4], 0

    call _getTime
    sub eax, edx
    
    

    mov ecx, 4
    mul ecx
    
    xor edx, edx
    xor ecx, ecx

int_string_loop:
    cmp eax, 0
    je reverse_string

    mov ebx, 10
    div ebx
    add dl, '0'
    mov byte[charge + ecx], dl
    inc ecx
    xor edx, edx
    jmp int_string_loop

reverse_string: 
    mov word[lenCharge], cx
    mov eax, ecx
    mov ebx, 2
    div ebx
    mov edx, eax

    mov esi, charge
    mov eax, esi
    movzx ebx, word[lenCharge]
    add eax, ebx
    mov edi, eax
    
    xor ecx, ecx 
reverse_string_loop:
    cmp esi, edi
    jge car_avail_cont 
    
    mov al, byte[esi]
    mov ah, byte[edi-1]
    
    mov byte[esi], ah
    mov byte[edi-1], al
    
    inc esi
    dec edi
    
    jmp reverse_string_loop


car_avail_cont:
    mov eax, 4
    mov ebx, 1
    mov ecx, carAvailMessage
    mov edx, lenCarAvailMessage
    int 0x80

    push lenRetrieveCharge
    mov ecx, retrieveCharge
    call _print

    push word[lenCharge]
    mov ecx, charge
    call _print

    int 0x80

    jmp program_entry

exit:
    ; Exit the program
    mov eax, 1
    int 0x80


_printStars:
    mov eax, 4                           
    mov ebx, 1                          
    mov ecx, stars           
    mov edx, 50        
    int 0x80                            
    ret

_print:
    push ebp
    mov ebp, esp

    mov eax, 4
    mov ebx, 1
    mov edx, [ebp + 8]
    int 0x80

    pop ebp
    ret

_getTime:
    mov eax, 13
    xor ebx, ebx
    int 0x80

    ret
