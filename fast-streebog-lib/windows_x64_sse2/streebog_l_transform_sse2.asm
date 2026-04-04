.data
ALIGN 16

INCLUDE streebog_precalc_tables_sse2.asm

.code

streebog_l_transform_sse2 PROC
    ; rcx = вход
    ; rdx = выход
    
    ; работа с регистрами
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    
    mov rsi, rcx ; теперь rsi = вход
    mov rdi, rdx ; теперь rdi = выход
    
    ; 8 блоков по 8 байтов каждый
    xor r12, r12 ; r12 = подсчет (0-7)
    
process_block:

    ; вгруз 8 байтов входа 
    movzx rax, BYTE PTR [rsi + r12*8 + 0] ; байт 0
    movzx rbx, BYTE PTR [rsi + r12*8 + 1] ; байт 1
    movzx rcx, BYTE PTR [rsi + r12*8 + 2] ; байт 2
    movzx r8,  BYTE PTR [rsi + r12*8 + 3] ; байт 3
    movzx r9,  BYTE PTR [rsi + r12*8 + 4] ; байт 4
    movzx r10, BYTE PTR [rsi + r12*8 + 5] ; байт 5
    movzx r11, BYTE PTR [rsi + r12*8 + 6] ; байт 6
    movzx r13, BYTE PTR [rsi + r12*8 + 7] ; байт 7
    
    ; начинаем ксорить, первый раз просто загрузка, потом сами ксоры
    lea r14, [Ax_COL0]
    mov r15, QWORD PTR [r14 + rax*8] ; r15 = Ax[0][байт0]
    
    lea r14, [Ax_COL1]
    xor r15, QWORD PTR [r14 + rbx*8] ; r15 ^= Ax[1][байт1]
    
    lea r14, [Ax_COL2]
    xor r15, QWORD PTR [r14 + rcx*8] ; r15 ^= Ax[2][байт2]
    
    lea r14, [Ax_COL3]
    xor r15, QWORD PTR [r14 + r8*8] ; r15 ^= Ax[3][байт3]
    
    lea r14, [Ax_COL4]
    xor r15, QWORD PTR [r14 + r9*8] ; r15 ^= Ax[4][байт4]
    
    lea r14, [Ax_COL5]
    xor r15, QWORD PTR [r14 + r10*8] ; r15 ^= Ax[5][байт5]
    
    lea r14, [Ax_COL6]
    xor r15, QWORD PTR [r14 + r11*8]  ; r15 ^= Ax[6][байт6]
    
    lea r14, [Ax_COL7]
    xor r15, QWORD PTR [r14 + r13*8] ; r15 ^= Ax[7][байт7]
    
    ; в биг энидан и сохраняем
    bswap r15
    mov QWORD PTR [rdi + r12*8], r15
    
    ; следующая итерация
    inc r12
    cmp r12, 8
    jl process_block
    
    ; работа с регистрамииииииииии
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret
streebog_l_transform_sse2 ENDP

END