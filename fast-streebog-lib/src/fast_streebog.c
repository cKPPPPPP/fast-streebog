#include "fast_streebog.h"
#include "streebog_impl.h"
#include <immintrin.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef STREEBOG_USE_ASM

// объявление всех функций, что у нас есть
// AVX-512
extern void streebog_xor_512(const uint8_t *, const uint8_t *, uint8_t *);
extern void streebog_add_512(const uint8_t *, const uint8_t *, uint8_t *);
extern void streebog_s_transform(const uint8_t *, uint8_t *);
extern void streebog_p_transform(const uint8_t *, uint8_t *);
extern void streebog_l_transform(const uint8_t *, uint8_t *);
extern void streebog_key_schedule(const uint8_t *, int, uint8_t *);

// AVX2
extern void streebog_xor_512_avx2(const uint8_t *, const uint8_t *, uint8_t *);
extern void streebog_add_512_avx2(const uint8_t *, const uint8_t *, uint8_t *);
extern void streebog_s_transform_avx2(const uint8_t *, uint8_t *);
extern void streebog_p_transform_avx2(const uint8_t *, uint8_t *);
extern void streebog_l_transform_avx2(const uint8_t *, uint8_t *);
extern void streebog_key_schedule_avx2(const uint8_t *, int, uint8_t *);

// SSE2
extern void streebog_xor_512_sse2(const uint8_t *, const uint8_t *, uint8_t *);
extern void streebog_add_512_sse2(const uint8_t *, const uint8_t *, uint8_t *);
extern void streebog_s_transform_sse2(const uint8_t *, uint8_t *);
extern void streebog_p_transform_sse2(const uint8_t *, uint8_t *);
extern void streebog_l_transform_sse2(const uint8_t *, uint8_t *);
extern void streebog_key_schedule_sse2(const uint8_t *, int, uint8_t *);

#endif

// дипсатчччччччччччч

typedef struct
{
    void (*xor_512)(const uint8_t *, const uint8_t *, uint8_t *);
    void (*add_512)(const uint8_t *, const uint8_t *, uint8_t *);
    void (*s_transform)(const uint8_t *, uint8_t *);
    void (*p_transform)(const uint8_t *, uint8_t *);
    void (*l_transform)(const uint8_t *, uint8_t *);
    void (*key_schedule)(const uint8_t *, int, uint8_t *);
} streebog_impl_t;

// инициализация
static streebog_impl_t g_impl;
static int g_initialized = 0;

#ifdef _MSC_VER
#include <intrin.h>
#endif

// если находим avx2 врубаем его и передаем ему регистры
// скажу честно с этим очень сильно помог неживой интеллект это пока не оч мой уровень(
static int has_avx2(void)
{
#ifdef _MSC_VER
    int info[4];

    __cpuid(info, 0);
    if (info[0] < 7)
        return 0;

    __cpuid(info, 1);
    if (!(info[2] & (1 << 27)))
        return 0;

    unsigned long long xcr = _xgetbv(0);
    if ((xcr & 0x6) != 0x6)
        return 0;

    __cpuidex(info, 7, 0);
    return (info[1] & (1 << 5)) != 0;
#else
    return 0;
#endif
}

// то же самое с avx512
static int has_avx512(void)
{
#ifdef _MSC_VER
    int info[4];

    __cpuid(info, 0);
    if (info[0] < 7)
        return 0;

    __cpuid(info, 1);
    if (!(info[2] & (1 << 27)))
        return 0;

    unsigned long long xcr = _xgetbv(0);
    if ((xcr & 0xE6) != 0xE6)
        return 0;

    __cpuidex(info, 7, 0);
    return (info[1] & (1 << 16)) != 0;
#else
    return 0;
#endif
}

// выбирает наилучушю версию (от большего к меньшему))
static void init_impl(void)
{
    // Сначала всё в NULL
    memset(&g_impl, 0, sizeof(g_impl));

#ifdef STREEBOG_USE_ASM

    // передача функций в avx512
    if (has_avx512())
    {
        g_impl.xor_512 = streebog_xor_512;
        g_impl.add_512 = streebog_add_512;
        g_impl.s_transform = streebog_s_transform;
        g_impl.p_transform = streebog_p_transform;
        g_impl.l_transform = streebog_l_transform;
        g_impl.key_schedule = streebog_key_schedule;
    }
    // передача функций в avx2
    else if (has_avx2())
    {
        g_impl.xor_512 = streebog_xor_512_avx2;
        g_impl.add_512 = streebog_add_512_avx2;
        g_impl.s_transform = streebog_s_transform_avx2;
        g_impl.p_transform = streebog_p_transform_avx2;
        g_impl.l_transform = streebog_l_transform_avx2;
        g_impl.key_schedule = streebog_key_schedule_avx2;
    }
    // передача функций в sse2 (без него код даже не скомпилируется)
    else
    {
        g_impl.xor_512 = streebog_xor_512_sse2;
        g_impl.add_512 = streebog_add_512_sse2;
        g_impl.s_transform = streebog_s_transform_sse2;
        g_impl.p_transform = streebog_p_transform_sse2;
        g_impl.l_transform = streebog_l_transform_sse2;
        g_impl.key_schedule = streebog_key_schedule_sse2;
    }

#endif

    // fallback на чистый C если ни одна ASM реализация не была выбрана ВООБЩЕ
    // срабатывает на платформах без поддержки STREEBOG_USE_ASM
    if (!g_impl.xor_512)
    {
        g_impl.xor_512 = streebog_xor_512_c;
        g_impl.add_512 = streebog_add_512_c;
        g_impl.s_transform = streebog_s_transform_c;
        g_impl.p_transform = streebog_p_transform_c;
        g_impl.l_transform = streebog_l_transform_c_inline;
        g_impl.key_schedule = streebog_key_schedule_c_inline;
    }

    g_initialized = 1;
}

// макрос для "ленивой инициализации диспатча", чтобы вызывать только кодга
#define ENSURE_IMPL()                                                                                                  \
    do                                                                                                                 \
    {                                                                                                                  \
        if (!g_initialized)                                                                                            \
            init_impl();                                                                                               \
    } while (0)

// гост требует биг энидан, вы мне сами говорили об этом, так что перед лен байтс надо перевернуть данные
#ifdef _MSC_VER
#include <intrin.h>
#define BSWAP64(x) _byteswap_uint64(x)
#else
#define BSWAP64(x) __builtin_bswap64(x)
#endif

#ifndef STREEBOG_VERSION
#define STREEBOG_VERSION "unknown"
#endif

// версия
STREEBOG_API const char *STREEBOG_NAMESPACE(version)(void)
{
    return STREEBOG_VERSION;
}

// вызываем функции
void STREEBOG_NAMESPACE(xor_512)(const uint8_t *a, const uint8_t *b, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.xor_512(a, b, out);
}

void STREEBOG_NAMESPACE(add_512)(const uint8_t *a, const uint8_t *b, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.add_512(a, b, out);
}

void STREEBOG_NAMESPACE(s_transform)(const uint8_t *state, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.s_transform(state, out);
}

void STREEBOG_NAMESPACE(p_transform)(const uint8_t *state, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.p_transform(state, out);
}

void STREEBOG_NAMESPACE(l_transform)(const uint8_t *state, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.l_transform(state, out);
}

void STREEBOG_NAMESPACE(key_schedule)(const uint8_t *K, int i, uint8_t *out)
{
    ENSURE_IMPL();
    g_impl.key_schedule(K, i, out);
}

// E transformation: E(K, m)
// Performs 12 rounds of S->P->L->KeySchedule->XOR
// Always use C implementation - it calls optimized ASM for S/P/L/KeySchedule

// больше не использует всегда си. немного переделанная версия, дабы оптимизировать avx2 версию
// выравнивание для нее же опять, а также отсутствие лишних копирований памяти
void streebog_e_transform(const uint8_t *K, const uint8_t *m, uint8_t *out)
{
#ifdef _MSC_VER
    __declspec(align(32)) uint8_t buf0[64];
    __declspec(align(32)) uint8_t buf1[64];
    __declspec(align(32)) uint8_t key[64];
    __declspec(align(32)) uint8_t tmp[64];
#else
    __attribute__((aligned(32))) uint8_t buf0[64];
    __attribute__((aligned(32))) uint8_t buf1[64];
    __attribute__((aligned(32))) uint8_t key[64];
    __attribute__((aligned(32))) uint8_t tmp[64];
#endif

    uint8_t *src = buf0;
    uint8_t *dst = buf1;

    STREEBOG_NAMESPACE(xor_512)(K, m, src);
    memcpy(key, K, 64);

    for (int i = 0; i < 12; i++)
    {
        STREEBOG_NAMESPACE(s_transform)(src, dst);

        uint8_t *t = src;
        src = dst;
        dst = t;

        STREEBOG_NAMESPACE(p_transform)(src, dst);

        t = src;
        src = dst;
        dst = t;

        STREEBOG_NAMESPACE(l_transform)(src, dst);

        t = src;
        src = dst;
        dst = t;

        STREEBOG_NAMESPACE(key_schedule)(key, i, tmp);
        memcpy(key, tmp, 64);

        STREEBOG_NAMESPACE(xor_512)(src, key, dst);

        t = src;
        src = dst;
        dst = t;
    }

    memcpy(out, src, 64);
}

// G_n compression function: g(N, h, m)
// K = L(P(S(h ^ N)))
// t = E(K, m)
// return t ^ h ^ m
// Always use C implementation - it calls optimized ASM for primitives
// добавил буфер tmp из-за траблов с инлпейс вызовом (в некоторых функциях мы попеременно читаем и записываем)
void STREEBOG_NAMESPACE(g_n)(const uint8_t *N, const uint8_t *h, const uint8_t *m, uint8_t *out)
{
    uint8_t K[64];
    uint8_t t[64];
    uint8_t tmp[64];

    // K = h ^ N
    STREEBOG_NAMESPACE(xor_512)(h, N, K);

    // K = S(K)
    STREEBOG_NAMESPACE(s_transform)(K, tmp);
    memcpy(K, tmp, 64);

    // K = P(K)
    STREEBOG_NAMESPACE(p_transform)(K, tmp);
    memcpy(K, tmp, 64);

    // K = L(K)
    STREEBOG_NAMESPACE(l_transform)(K, tmp);
    memcpy(K, tmp, 64);

    // t = E(K, m)
    STREEBOG_NAMESPACE(e_transform)(K, m, t);

    // t = t ^ h
    STREEBOG_NAMESPACE(xor_512)(t, h, tmp);

    // out = t ^ m
    STREEBOG_NAMESPACE(xor_512)(tmp, m, out);
}

// Initialize hash context for 512-bit output
void STREEBOG_NAMESPACE(init_512)(streebog_ctx *ctx)
{
    memset(ctx->h, 0x00, 64);
    memset(ctx->N, 0x00, 64);
    memset(ctx->Sigma, 0x00, 64);
    ctx->msg_buf = NULL;
    ctx->msg_len = 0;
    ctx->msg_cap = 0;
    ctx->out_len = 512;
}

// Initialize hash context for 256-bit output
void STREEBOG_NAMESPACE(init_256)(streebog_ctx *ctx)
{
    memset(ctx->h, 0x01, 64);
    memset(ctx->N, 0x00, 64);
    memset(ctx->Sigma, 0x00, 64);
    ctx->msg_buf = NULL;
    ctx->msg_len = 0;
    ctx->msg_cap = 0;
    ctx->out_len = 256;
}

// Process a full 512-bit block
static void process_block(streebog_ctx *ctx, const uint8_t *block)
{
    uint8_t tmp[64];
    // N_512 = 512 as 64-byte big-endian
    static const uint8_t N_512[64] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    // h = g(N, h, m)
    STREEBOG_NAMESPACE(g_n)(ctx->N, ctx->h, block, ctx->h);

    // N = (N + 512) mod 2^512
    STREEBOG_NAMESPACE(add_512)(ctx->N, N_512, tmp);
    memcpy(ctx->N, tmp, 64);

    // Sigma = (Sigma + m) mod 2^512
    STREEBOG_NAMESPACE(add_512)(ctx->Sigma, block, tmp);
    memcpy(ctx->Sigma, tmp, 64);
}

// Update hash with data (accumulates data for processing in final)
void STREEBOG_NAMESPACE(update)(streebog_ctx *ctx, const uint8_t *data, size_t len)
{
    if (len == 0)
        return;

    // Grow buffer if needed
    size_t new_len = ctx->msg_len + len;
    if (new_len > ctx->msg_cap)
    {
        size_t new_cap = ctx->msg_cap == 0 ? 256 : ctx->msg_cap;
        while (new_cap < new_len)
        {
            new_cap *= 2;
        }
        uint8_t *new_buf = (uint8_t *)realloc(ctx->msg_buf, new_cap);
        if (!new_buf)
            return; // allocation failed
        ctx->msg_buf = new_buf;
        ctx->msg_cap = new_cap;
    }

    // Append data
    memcpy(ctx->msg_buf + ctx->msg_len, data, len);
    ctx->msg_len += len;
}

// Finalize hash and get result
void STREEBOG_NAMESPACE(final)(streebog_ctx *ctx, uint8_t *out)
{
    uint8_t padded[64];
    uint8_t N_0[64] = {0};
    uint8_t len_bytes[64] = {0};

    // Total message length
    size_t total_len = ctx->msg_len;

    // Reverse the entire message buffer in-place (one pass)
    // This converts from natural byte order to GOST little-endian
    if (total_len > 1)
    {
        size_t left = 0;
        size_t right = total_len - 1;
        while (left < right)
        {
            uint8_t tmp = ctx->msg_buf[left];
            ctx->msg_buf[left] = ctx->msg_buf[right];
            ctx->msg_buf[right] = tmp;
            left++;
            right--;
        }
    }

    // Now process blocks sequentially (data is already reversed)
    size_t pos = 0;
    while (pos + 64 <= total_len)
    {
        process_block(ctx, ctx->msg_buf + pos);
        pos += 64;
    }

    // Remaining bytes
    size_t remainder = total_len - pos;

    // Pad the message: 0...0 || 1 || M
    // Message length in bits
    size_t msg_bits = remainder * 8;

    // Create padded block
    memset(padded, 0, 64);
    if (remainder > 0)
    {
        // Copy remainder into right side of padded (already reversed)
        memcpy(padded + (64 - remainder), ctx->msg_buf + pos, remainder);
    }
    // Set the '1' bit after padding zeros
    padded[64 - remainder - 1] = 0x01;

    // h = g(N, h, padded)
    STREEBOG_NAMESPACE(g_n)(ctx->N, ctx->h, padded, ctx->h);

    // N = (N + |M|) mod 2^512, where |M| is message length in bits
    // Store msg_bits as big-endian 64-bit value at offset 56
    // Using byte swap intrinsic - compiles to single BSWAP instruction
    *(uint64_t *)(len_bytes + 56) = BSWAP64((uint64_t)msg_bits);

    STREEBOG_NAMESPACE(add_512)(ctx->N, len_bytes, ctx->N);

    // Sigma = (Sigma + padded) mod 2^512
    STREEBOG_NAMESPACE(add_512)(ctx->Sigma, padded, ctx->Sigma);

    // h = g(0, h, N)
    STREEBOG_NAMESPACE(g_n)(N_0, ctx->h, ctx->N, ctx->h);

    // h = g(0, h, Sigma)
    STREEBOG_NAMESPACE(g_n)(N_0, ctx->h, ctx->Sigma, ctx->h);

    // Output result - reverse byte order for GOST standard representation
    if (ctx->out_len == 512)
    {
        for (int i = 0; i < 64; i++)
        {
            out[i] = ctx->h[63 - i];
        }
    }
    else
    {
        // For 256-bit, return MSB256(h) which is first 32 bytes of reversed hash
        for (int i = 0; i < 32; i++)
        {
            out[i] = ctx->h[31 - i];
        }
    }

    // Free buffer
    if (ctx->msg_buf)
    {
        free(ctx->msg_buf);
        ctx->msg_buf = NULL;
    }
    ctx->msg_len = 0;
    ctx->msg_cap = 0;
}

// Simple one-shot hash function for 512-bit output
void STREEBOG_NAMESPACE(hash_512)(const uint8_t *data, size_t len, uint8_t *out)
{
    streebog_ctx ctx;
    STREEBOG_NAMESPACE(init_512)(&ctx);
    STREEBOG_NAMESPACE(update)(&ctx, data, len);
    STREEBOG_NAMESPACE(final)(&ctx, out);
}

// Simple one-shot hash function for 256-bit output
void STREEBOG_NAMESPACE(hash_256)(const uint8_t *data, size_t len, uint8_t *out)
{
    streebog_ctx ctx;
    STREEBOG_NAMESPACE(init_256)(&ctx);
    STREEBOG_NAMESPACE(update)(&ctx, data, len);
    STREEBOG_NAMESPACE(final)(&ctx, out);
}

// ==================== Hex string functions ====================

static const char HEX_CHARS[] = "0123456789abcdef";

// Convert raw hash bytes to hex string
void STREEBOG_NAMESPACE(bytes_to_hex)(const uint8_t *hash, size_t hash_len, char *out)
{
    for (size_t i = 0; i < hash_len; i++)
    {
        out[i * 2] = HEX_CHARS[(hash[i] >> 4) & 0x0F];
        out[i * 2 + 1] = HEX_CHARS[hash[i] & 0x0F];
    }
    out[hash_len * 2] = '\0';
}

// Compute 512-bit hash and return as hex string
void STREEBOG_NAMESPACE(hash_512_hex)(const uint8_t *data, size_t len, char *out)
{
    uint8_t hash[64];
    STREEBOG_NAMESPACE(hash_512)(data, len, hash);
    STREEBOG_NAMESPACE(bytes_to_hex)(hash, 64, out);
}

// Compute 256-bit hash and return as hex string
void STREEBOG_NAMESPACE(hash_256_hex)(const uint8_t *data, size_t len, char *out)
{
    uint8_t hash[32];
    STREEBOG_NAMESPACE(hash_256)(data, len, hash);
    STREEBOG_NAMESPACE(bytes_to_hex)(hash, 32, out);
}

// ==================== File hashing API ====================

// Hash file and compute both 256-bit and 512-bit hashes in one pass
// Optimized for FFI usage - single function call eliminates FFI overhead
int STREEBOG_NAMESPACE(hash_file_dual)(const char *filepath, uint8_t *hash_256, uint8_t *hash_512,
                                       void (*progress_callback)(size_t bytes_processed, size_t total_size,
                                                                 void *user_data),
                                       void *user_data)
{
    // Validate parameters
    if (hash_256 == NULL && hash_512 == NULL)
    {
        return -3;
    }

    FILE *file = fopen(filepath, "rb");
    if (file == NULL)
    {
        return -1;
    }

    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);

    streebog_ctx ctx_256, ctx_512;
    if (hash_256 != NULL)
    {
        STREEBOG_NAMESPACE(init_256)(&ctx_256);
    }
    if (hash_512 != NULL)
    {
        STREEBOG_NAMESPACE(init_512)(&ctx_512);
    }

    uint8_t buffer[65536];
    size_t bytes_read;
    size_t bytes_processed = 0;

    while ((bytes_read = fread(buffer, 1, sizeof(buffer), file)) > 0)
    {
        if (hash_256 != NULL)
        {
            STREEBOG_NAMESPACE(update)(&ctx_256, buffer, bytes_read);
        }
        if (hash_512 != NULL)
        {
            STREEBOG_NAMESPACE(update)(&ctx_512, buffer, bytes_read);
        }

        bytes_processed += bytes_read;

        if (progress_callback != NULL)
        {
            progress_callback(bytes_processed, (size_t)file_size, user_data);
        }
    }

    if (ferror(file))
    {
        fclose(file);
        return -2;
    }

    fclose(file);

    if (hash_256 != NULL)
    {
        STREEBOG_NAMESPACE(final)(&ctx_256, hash_256);
    }
    if (hash_512 != NULL)
    {
        STREEBOG_NAMESPACE(final)(&ctx_512, hash_512);
    }

    return 0;
}