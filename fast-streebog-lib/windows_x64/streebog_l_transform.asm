.data
ALIGN 64 ; выравние до 64 изза avx-512

CONST_FF dq 8 DUP (000000000000000FFh) ; константа для доставания элементов, 8 раз по FF на конце

INCLUDE streebog_precalc_tables.asm

.code

streebog_l_transform PROC

    vmovdqa64 zmm8,  ZMMWORD PTR [rcx]          ; вгруз входных данных за раз
    vmovdqa64 zmm10, ZMMWORD PTR [CONST_FF]     ; загрузка константы, которой мы будем манипулировать

    ; каждый нулевой байт из всех колонн
    vpandq    zmm9,  zmm8,  zmm10               ; в 9 змм грузим нулевые байты
    vmovdqa64 zmm0,  ZMMWORD PTR [Ax_COL0]
    vpermb    zmm16, zmm9,  zmm0                ; вгрузв в 16 змм нулевого байта всех значений

    ; первый байт
    vpsrlq    zmm9,  zmm8,  8                   ; сдвиг вправо одного байта
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm1,  ZMMWORD PTR [Ax_COL1]
    vpermb    zmm17, zmm9,  zmm1

    ; второй байт
    vpsrlq    zmm9,  zmm8,  16
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm2,  ZMMWORD PTR [Ax_COL2]
    vpermb    zmm18, zmm9,  zmm2

    ; третий байт
    vpsrlq    zmm9,  zmm8,  24
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm3,  ZMMWORD PTR [Ax_COL3]
    vpermb    zmm19, zmm9,  zmm3

    ; четвертый байт
    vpsrlq    zmm9,  zmm8,  32
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm4,  ZMMWORD PTR [Ax_COL4]
    vpermb    zmm20, zmm9,  zmm4

    ; пятый байт
    vpsrlq    zmm9,  zmm8,  40
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm5,  ZMMWORD PTR [Ax_COL5]
    vpermb    zmm21, zmm9,  zmm5

    ; шестой байт
    vpsrlq    zmm9,  zmm8,  48
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm6,  ZMMWORD PTR [Ax_COL6]
    vpermb    zmm22, zmm9,  zmm6

    ; седьмой байт
    vpsrlq    zmm9,  zmm8,  56
    vpandq    zmm9,  zmm9,  zmm10
    vmovdqa64 zmm7,  ZMMWORD PTR [Ax_COL7]
    vpermb    zmm23, zmm9,  zmm7

    ; ксор всех элементов, происходят параллельно
    vpxorq    zmm16, zmm16, zmm17
    vpxorq    zmm18, zmm18, zmm19
    vpxorq    zmm20, zmm20, zmm21
    vpxorq    zmm22, zmm22, zmm23

    vpxorq    zmm16, zmm16, zmm18
    vpxorq    zmm20, zmm20, zmm22

    vpxorq    zmm24, zmm16, zmm20

    vmovdqa64 ZMMWORD PTR [rdx], zmm24 ; загружаем в ответ
    vzeroupper

    ret
streebog_l_transform ENDP
END