    global sepia
    section .text

sepia:
    ; prologue
    ; [ebp-4] -> end of image pointer
    push ebp
    mov ebp, esp
    sub esp, 4

    push ebx
    push esi
    push edi

    ; calculate end pointer of array: width*height*3
    mov eax, [ebp+12]
    mov edx, [ebp+16]
    mul edx
    mov edx, 3
    mul edx

    mov edx, [ebp+8]
    add edx, eax
    mov [ebp-4], edx

    ; ecx -> image iterator
    mov ecx, [ebp+8]

sepiaLoop:
    ; load colors to registers:
    ; edi -> blue
    ; ebx -> green
    ; esi -> red
    movzx edi, byte [ecx]
    movzx ebx, byte [ecx+1]
    movzx esi, byte [ecx+2]

    ; calculate new blue component
    ; new_blue = (red*272)/1024 + (green*534)/1024 + (blue*131)/1024
    mov eax, esi
    imul eax, 272
    shr eax, 10
    mov edx, eax

    mov eax, ebx
    imul eax, 534
    shr eax, 10
    add edx, eax

    mov eax, edi
    imul eax, 131
    shr eax, 10
    add edx, eax

    mov eax, 255
    cmp edx, eax
    cmova edx, eax
    mov byte [ecx], dl
    inc ecx

    ; calculate new green component
    ; new_green = (red*349)/1024 + (green*686)/1024 + (blue*168)/1024
    mov eax, esi
    imul eax, 349
    shr eax, 10
    mov edx, eax

    mov eax, ebx
    imul eax, 686
    shr eax, 10
    add edx, eax

    mov eax, edi
    imul eax, 168
    shr eax, 10
    add edx, eax

    mov eax, 255
    cmp edx, eax
    cmova edx, eax
    mov byte [ecx], dl
    inc ecx

    ; calculate new red component
    ; new_red = (red*393)/1024 + (green*769)/1024 + (blue*189)/1024
    mov eax, esi
    imul eax, 393
    shr eax, 10
    mov edx, eax

    mov eax, ebx
    imul eax, 769
    shr eax, 10
    add edx, eax

    mov eax, edi
    imul eax, 189
    shr eax, 10
    add edx, eax

    mov eax, 255
    cmp edx, eax
    cmova edx, eax
    mov byte [ecx], dl
    inc ecx

    ; loop condition
    cmp ecx, [ebp-4]
    jb sepiaLoop

    ; epilogue
    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ret