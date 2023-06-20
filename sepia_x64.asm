    global sepia
    section .text

sepia:
    ; prologue
    push rbp
    mov rbp, rsp
    
    ; calculate end pointer of array: width*height*3
    ; rdx -> end of image
    ; rdi -> image iterator
    mov eax, edx
    mul esi
    lea eax, [eax + eax*2]

    mov rdx, rdi
    add rdx, rax
    
sepiaLoop:
    ; load colors to stack variables
    ; r9d -> blue
    ; r10d -> green
    ; r11d -> red
    movzx r9d, byte [rdi]
    movzx r10d, byte [rdi+1]
    movzx r11d, byte [rdi+2]

    ; calculate new blue component
    ; new_blue = (red*272)/1024 + (green*534)/1024 + (blue*131)/1024
    mov eax, r11d
    imul eax, 272
    shr eax, 10
    mov esi, eax
    
    mov eax, r10d
    imul eax, 534
    shr eax, 10
    add esi, eax
    
    mov eax, r9d
    imul eax, 131
    shr eax, 10
    add esi, eax

    mov eax, 255
    cmp esi, eax
    cmova esi, eax
    mov byte [rdi], sil
    inc rdi
    
    ; calculate new green component
    ; new_green = (red*349)/1024 + (green*686)/1024 + (blue*168)/1024
    mov eax, r11d
    imul eax, 349
    shr eax, 10
    mov esi, eax

    mov eax, r10d
    imul eax, 686
    shr eax, 10
    add esi, eax

    mov eax, r9d
    imul eax, 168
    shr eax, 10
    add esi, eax

    mov eax, 255
    cmp esi, eax
    cmova esi, eax
    mov byte [rdi], sil
    inc rdi

    ; calculate new red component
    ; new_red = (red*393)/1024 + (green*769)/1024 + (blue*189)/1024
    mov eax, r11d
    imul eax, 393
    shr eax, 10
    mov esi, eax

    mov eax, r10d
    imul eax, 769
    shr eax, 10
    add esi, eax

    mov eax, r9d
    imul eax, 189
    shr eax, 10
    add esi, eax

    mov eax, 255
    cmp esi, eax
    cmova esi, eax
    mov byte [rdi], sil
    inc rdi

    ; loop condition
    cmp rdi, rdx
    jb sepiaLoop
    
    ; epilogue
    mov rsp, rbp
    pop rbp
    ret
