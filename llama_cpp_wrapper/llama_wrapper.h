#pragma once

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef void* llama_ctx_t;

EXPORT llama_ctx_t llama_load_model(const char* model_path);
EXPORT void llama_wrapper_free_model(llama_ctx_t ctx); // Renamed to avoid conflict
EXPORT const char* llama_generate_advanced(
    llama_ctx_t ctx,
    const char* prompt,
    unsigned int max_tokens,
    unsigned int top_k,
    double top_p,
    double temperature,
    double repeat_penalty,
    unsigned int seed
);

#ifdef __cplusplus
}
#endif
