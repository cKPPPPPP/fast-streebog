.DATA
ALIGN 16

; суть работы вдохновлена s_transform из армы. Я обнуляю ненужные элементы(0x80=128 - колво бит в инструкции), а потом складываю для получения результата
; tran[x][y] - где x это какие 2 байта ячейки мы берем, а y это какой из xmm используем (берем по 2 из-за особенности нашей матрицы)
; p_transform - простое транспонирование матрицы, так что с помощью масок двигаем элементы так, как захотим, а потом складываем
; для понимания можно матрицу написать и понять, что, хотя она и 8X8, но один кусок(xmm0 например) - это целых 2 строки, отсюда и возникают странные смещения

; для элементов нулевой группы
tran00 DB 00h, 08h, 080h, 080h, 080h, 080h, 080h, 080h, 01h, 09h, 080h, 080h, 080h, 080h, 080h, 080h
tran01 DB 080h, 080h, 00h, 08h, 080h, 080h, 080h, 080h, 080h, 080h, 01h, 09h, 080h, 080h, 080h, 080h
tran02 DB 080h, 080h, 080h, 080h, 00h, 08h, 080h, 080h, 080h, 080h, 080h, 080h, 01h, 09h, 080h, 080h
tran03 DB 080h, 080h, 080h, 080h, 080h, 080h, 00h, 08h, 080h, 080h, 080h, 080h, 080h, 080h, 01h, 09h

; для элементов 1 группы
tran10 DB 02h, 0Ah, 080h, 080h, 080h, 080h, 080h, 080h, 03h, 0Bh, 080h, 080h, 080h, 080h, 080h, 080h
tran11 DB 080h, 080h, 02h, 0Ah, 080h, 080h, 080h, 080h, 080h, 080h, 03h, 0Bh, 080h, 080h, 080h, 080h
tran12 DB 080h, 080h, 080h, 080h, 02h, 0Ah, 080h, 080h, 080h, 080h, 080h, 080h, 03h, 0Bh, 080h, 080h
tran13 DB 080h, 080h, 080h, 080h, 080h, 080h, 02h, 0Ah, 080h, 080h, 080h, 080h, 080h, 080h, 03h, 0Bh

; для элементов 2 группы
tran20 DB 04h, 0Ch, 080h, 080h, 080h, 080h, 080h, 080h, 05h, 0Dh, 080h, 080h, 080h, 080h, 080h, 080h
tran21 DB 080h, 080h, 04h, 0Ch, 080h, 080h, 080h, 080h, 080h, 080h, 05h, 0Dh, 080h, 080h, 080h, 080h
tran22 DB 080h, 080h, 080h, 080h, 04h, 0Ch, 080h, 080h, 080h, 080h, 080h, 080h, 05h, 0Dh, 080h, 080h
tran23 DB 080h, 080h, 080h, 080h, 080h, 080h, 04h, 0Ch, 080h, 080h, 080h, 080h, 080h, 080h, 05h, 0Dh

; для элементов 3 группы
tran30 DB 06h, 0Eh, 080h, 080h, 080h, 080h, 080h, 080h, 07h, 0Fh, 080h, 080h, 080h, 080h, 080h, 080h
tran31 DB 080h, 080h, 06h, 0Eh, 080h, 080h, 080h, 080h, 080h, 080h, 07h, 0Fh, 080h, 080h, 080h, 080h
tran32 DB 080h, 080h, 080h, 080h, 06h, 0Eh, 080h, 080h, 080h, 080h, 080h, 080h, 07h, 0Fh, 080h, 080h
tran33 DB 080h, 080h, 080h, 080h, 080h, 080h, 06h, 0Eh, 080h, 080h, 080h, 080h, 080h, 080h, 07h, 0Fh

.CODE
streebog_p_transform_sse2 PROC
    ; rcx = вход, rdx = выход

    ; загружаем 4 куска входа
    movdqu xmm0, XMMWORD PTR [rcx +  0]
    movdqu xmm1, XMMWORD PTR [rcx + 16]
    movdqu xmm2, XMMWORD PTR [rcx + 32]
    movdqu xmm3, XMMWORD PTR [rcx + 48]

    ; байты 0-15 (группа 0)
    movdqa xmm4, xmm0
    pshufb xmm4, XMMWORD PTR [tran00]       ; из куска 0 берём нужные байты
    movdqa xmm5, xmm1
    pshufb xmm5, XMMWORD PTR [tran01]       ; из куска 1
    por xmm4, xmm5
    movdqa xmm5, xmm2
    pshufb xmm5, XMMWORD PTR [tran02]       ; из куска 2
    por xmm4, xmm5
    movdqa xmm5, xmm3
    pshufb xmm5, XMMWORD PTR [tran03]       ; из куска 3
    por xmm4, xmm5
    movdqu XMMWORD PTR [rdx +  0], xmm4     ; записываем результат

    ; байты 16-31 (группа 1)
    movdqa xmm4, xmm0
    pshufb xmm4, XMMWORD PTR [tran10]
    movdqa xmm5, xmm1
    pshufb xmm5, XMMWORD PTR [tran11]
    por xmm4, xmm5
    movdqa xmm5, xmm2
    pshufb xmm5, XMMWORD PTR [tran12]
    por xmm4, xmm5
    movdqa xmm5, xmm3
    pshufb xmm5, XMMWORD PTR [tran13]
    por xmm4, xmm5
    movdqu XMMWORD PTR [rdx + 16], xmm4

    ; байты 32-47 (группа 2)
    movdqa xmm4, xmm0
    pshufb xmm4, XMMWORD PTR [tran20]
    movdqa xmm5, xmm1
    pshufb xmm5, XMMWORD PTR [tran21]
    por xmm4, xmm5
    movdqa xmm5, xmm2
    pshufb xmm5, XMMWORD PTR [tran22]
    por xmm4, xmm5
    movdqa xmm5, xmm3
    pshufb xmm5, XMMWORD PTR [tran23]
    por xmm4, xmm5
    movdqu XMMWORD PTR [rdx + 32], xmm4

    ; батйты 48-63 (группа 3)
    movdqa xmm4, xmm0
    pshufb xmm4, XMMWORD PTR [tran30]
    movdqa xmm5, xmm1
    pshufb xmm5, XMMWORD PTR [tran31]
    por xmm4, xmm5
    movdqa xmm5, xmm2
    pshufb xmm5, XMMWORD PTR [tran32]
    por xmm4, xmm5
    movdqa xmm5, xmm3
    pshufb xmm5, XMMWORD PTR [tran33]
    por xmm4, xmm5
    movdqu XMMWORD PTR [rdx + 48], xmm4

    ret
streebog_p_transform_sse2 ENDP
END