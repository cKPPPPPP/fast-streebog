.DATA
ALIGN 16

; переход 0 (tran = transition)
tran00 DB 00h,08h,80h,80h,80h,80h,80h,80h,01h,09h,80h,80h,80h,80h,80h,80h
tran01 DB 80h,80h,00h,08h,80h,80h,80h,80h,80h,80h,01h,09h,80h,80h,80h,80h
tran02 DB 80h,80h,80h,80h,00h,08h,80h,80h,80h,80h,80h,80h,01h,09h,80h,80h
tran03 DB 80h,80h,80h,80h,80h,80h,00h,08h,80h,80h,80h,80h,80h,80h,01h,09h

; переход 1
tran10 DB 02h,0Ah,80h,80h,80h,80h,80h,80h,03h,0Bh,80h,80h,80h,80h,80h,80h
tran11 DB 80h,80h,02h,0Ah,80h,80h,80h,80h,80h,80h,03h,0Bh,80h,80h,80h,80h
tran12 DB 80h,80h,80h,80h,02h,0Ah,80h,80h,80h,80h,80h,80h,03h,0Bh,80h,80h
tran13 DB 80h,80h,80h,80h,80h,80h,02h,0Ah,80h,80h,80h,80h,80h,80h,03h,0Bh

; переход 2
tran20 DB 04h,0Ch,80h,80h,80h,80h,80h,80h,05h,0Dh,80h,80h,80h,80h,80h,80h
tran21 DB 80h,80h,04h,0Ch,80h,80h,80h,80h,80h,80h,05h,0Dh,80h,80h,80h,80h
tran22 DB 80h,80h,80h,80h,04h,0Ch,80h,80h,80h,80h,80h,80h,05h,0Dh,80h,80h
tran23 DB 80h,80h,80h,80h,80h,80h,04h,0Ch,80h,80h,80h,80h,80h,80h,05h,0Dh

; переход 3
tran30 DB 06h,0Eh,80h,80h,80h,80h,80h,80h,07h,0Fh,80h,80h,80h,80h,80h,80h
tran31 DB 80h,80h,06h,0Eh,80h,80h,80h,80h,80h,80h,07h,0Fh,80h,80h,80h,80h
tran32 DB 80h,80h,80h,80h,06h,0Eh,80h,80h,80h,80h,80h,80h,07h,0Fh,80h,80h
tran33 DB 80h,80h,80h,80h,80h,80h,06h,0Eh,80h,80h,80h,80h,80h,80h,07h,0Fh

.CODE

; каждое расписывать тут бессмысленно - я в пеинте рисовал матрички чтобы понять, как их переставлять
; из-за того, что это просто транспонирование матрицы я имею полное право менять их как захочу
streebog_p_transform_avx2 PROC
    ; rcx = вход
    ; rdx = выход

    ; вгруз данных в xmm, но шафл с приставкой "v"
    vmovdqu xmm0, XMMWORD PTR [rcx +  0]
    vmovdqu xmm1, XMMWORD PTR [rcx + 16]
    vmovdqu xmm2, XMMWORD PTR [rcx + 32]
    vmovdqu xmm3, XMMWORD PTR [rcx + 48]

    ; для нулевого перехода
    vmovdqa xmm4, xmm0
    vpshufb xmm4, xmm4, XMMWORD PTR [tran00]

    vmovdqa xmm5, xmm1
    vpshufb xmm5, xmm5, XMMWORD PTR [tran01]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm2
    vpshufb xmm5, xmm5, XMMWORD PTR [tran02]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm3
    vpshufb xmm5, xmm5, XMMWORD PTR [tran03]
    vpor xmm4, xmm4, xmm5

    vmovdqu XMMWORD PTR [rdx + 0], xmm4

    ; для первого перехода
    vmovdqa xmm4, xmm0
    vpshufb xmm4, xmm4, XMMWORD PTR [tran10]

    vmovdqa xmm5, xmm1
    vpshufb xmm5, xmm5, XMMWORD PTR [tran11]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm2
    vpshufb xmm5, xmm5, XMMWORD PTR [tran12]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm3
    vpshufb xmm5, xmm5, XMMWORD PTR [tran13]
    vpor xmm4, xmm4, xmm5

    vmovdqu XMMWORD PTR [rdx + 16], xmm4

    ; для второго перехода
    vmovdqa xmm4, xmm0
    vpshufb xmm4, xmm4, XMMWORD PTR [tran20]

    vmovdqa xmm5, xmm1
    vpshufb xmm5, xmm5, XMMWORD PTR [tran21]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm2
    vpshufb xmm5, xmm5, XMMWORD PTR [tran22]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm3
    vpshufb xmm5, xmm5, XMMWORD PTR [tran23]
    vpor xmm4, xmm4, xmm5

    vmovdqu XMMWORD PTR [rdx + 32], xmm4

    ; для третьего перехода
    vmovdqa xmm4, xmm0
    vpshufb xmm4, xmm4, XMMWORD PTR [tran30]

    vmovdqa xmm5, xmm1
    vpshufb xmm5, xmm5, XMMWORD PTR [tran31]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm2
    vpshufb xmm5, xmm5, XMMWORD PTR [tran32]
    vpor xmm4, xmm4, xmm5

    vmovdqa xmm5, xmm3
    vpshufb xmm5, xmm5, XMMWORD PTR [tran33]
    vpor xmm4, xmm4, xmm5

    vmovdqu XMMWORD PTR [rdx + 48], xmm4

    vzeroupper
    ret
streebog_p_transform_avx2 ENDP

END