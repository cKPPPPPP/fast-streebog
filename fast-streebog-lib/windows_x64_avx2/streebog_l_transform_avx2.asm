.data
ALIGN 16

INCLUDE streebog_precalc_tables_avx2.asm

.code

streebog_l_transform_avx2 PROC
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    push    r14
    push    r15

    mov     rsi, rcx ; вход
    mov     rdi, rdx ; выход

    ; предзагружаем данные (бомба ваще )
    prefetcht0 [rsi]
    prefetcht0 [rsi + 32]

    mov     rax, OFFSET Ax_T ; указатель на таблички

    ; строка 0
    ; загружаем в разные регистры первые 8 байт
    movzx   r8,  BYTE PTR [rsi + 0]
    movzx   r9,  BYTE PTR [rsi + 1]
    movzx   r10, BYTE PTR [rsi + 2]
    movzx   r11, BYTE PTR [rsi + 3]
    movzx   r12, BYTE PTR [rsi + 4]
    movzx   r13, BYTE PTR [rsi + 5]
    movzx   r14, BYTE PTR [rsi + 6]
    movzx   r15, BYTE PTR [rsi + 7]

    ; умноэение на 6*8 для смещения нормального
    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    ; первую загружаем а потом сразу вход и ксор
    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx ; требует биг эндиан
    mov     [rdi + 0], rbx

    ; строка 1
    movzx   r8,  BYTE PTR [rsi + 8]
    movzx   r9,  BYTE PTR [rsi + 9]
    movzx   r10, BYTE PTR [rsi + 10]
    movzx   r11, BYTE PTR [rsi + 11]
    movzx   r12, BYTE PTR [rsi + 12]
    movzx   r13, BYTE PTR [rsi + 13]
    movzx   r14, BYTE PTR [rsi + 14]
    movzx   r15, BYTE PTR [rsi + 15]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 8], rbx

    ; строка 2
    movzx   r8,  BYTE PTR [rsi + 16]
    movzx   r9,  BYTE PTR [rsi + 17]
    movzx   r10, BYTE PTR [rsi + 18]
    movzx   r11, BYTE PTR [rsi + 19]
    movzx   r12, BYTE PTR [rsi + 20]
    movzx   r13, BYTE PTR [rsi + 21]
    movzx   r14, BYTE PTR [rsi + 22]
    movzx   r15, BYTE PTR [rsi + 23]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 16], rbx

    ; строка 3
    movzx   r8,  BYTE PTR [rsi + 24]
    movzx   r9,  BYTE PTR [rsi + 25]
    movzx   r10, BYTE PTR [rsi + 26]
    movzx   r11, BYTE PTR [rsi + 27]
    movzx   r12, BYTE PTR [rsi + 28]
    movzx   r13, BYTE PTR [rsi + 29]
    movzx   r14, BYTE PTR [rsi + 30]
    movzx   r15, BYTE PTR [rsi + 31]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 24], rbx

    ; строка 4
    movzx   r8,  BYTE PTR [rsi + 32]
    movzx   r9,  BYTE PTR [rsi + 33]
    movzx   r10, BYTE PTR [rsi + 34]
    movzx   r11, BYTE PTR [rsi + 35]
    movzx   r12, BYTE PTR [rsi + 36]
    movzx   r13, BYTE PTR [rsi + 37]
    movzx   r14, BYTE PTR [rsi + 38]
    movzx   r15, BYTE PTR [rsi + 39]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 32], rbx

    ; строка 5
    movzx   r8,  BYTE PTR [rsi + 40]
    movzx   r9,  BYTE PTR [rsi + 41]
    movzx   r10, BYTE PTR [rsi + 42]
    movzx   r11, BYTE PTR [rsi + 43]
    movzx   r12, BYTE PTR [rsi + 44]
    movzx   r13, BYTE PTR [rsi + 45]
    movzx   r14, BYTE PTR [rsi + 46]
    movzx   r15, BYTE PTR [rsi + 47]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 40], rbx

    ; строка 6
    movzx   r8,  BYTE PTR [rsi + 48]
    movzx   r9,  BYTE PTR [rsi + 49]
    movzx   r10, BYTE PTR [rsi + 50]
    movzx   r11, BYTE PTR [rsi + 51]
    movzx   r12, BYTE PTR [rsi + 52]
    movzx   r13, BYTE PTR [rsi + 53]
    movzx   r14, BYTE PTR [rsi + 54]
    movzx   r15, BYTE PTR [rsi + 55]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 48], rbx

    ; 7
    movzx   r8,  BYTE PTR [rsi + 56]
    movzx   r9,  BYTE PTR [rsi + 57]
    movzx   r10, BYTE PTR [rsi + 58]
    movzx   r11, BYTE PTR [rsi + 59]
    movzx   r12, BYTE PTR [rsi + 60]
    movzx   r13, BYTE PTR [rsi + 61]
    movzx   r14, BYTE PTR [rsi + 62]
    movzx   r15, BYTE PTR [rsi + 63]

    shl     r8, 6
    shl     r9, 6
    shl     r10,6
    shl     r11,6
    shl     r12,6
    shl     r13,6
    shl     r14,6
    shl     r15,6

    mov     rbx, [rax + r8  + 0]
    xor     rbx, [rax + r9  + 8]
    xor     rbx, [rax + r10 + 16]
    xor     rbx, [rax + r11 + 24]
    xor     rbx, [rax + r12 + 32]
    xor     rbx, [rax + r13 + 40]
    xor     rbx, [rax + r14 + 48]
    xor     rbx, [rax + r15 + 56]
    bswap   rbx
    mov     [rdi + 56], rbx


    vzeroupper

    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx
    ret
streebog_l_transform_avx2 ENDP

END
