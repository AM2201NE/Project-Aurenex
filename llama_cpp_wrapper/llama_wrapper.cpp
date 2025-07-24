#include "llama_wrapper.h"
#include "llama.h"
#include <windows.h>
#include <string>
#include <vector>
#include <random>
#include <algorithm>
#include <mutex>
#include <iostream>

static std::string last_output;
static std::mutex output_mutex;

llama_ctx_t llama_load_model(const char* model_path) {
    struct llama_context_params params = llama_context_default_params();
    struct llama_model_params mparams = llama_model_default_params();
    struct llama_model* model = llama_load_model_from_file(model_path, mparams);
    if (!model) return nullptr;
    struct llama_context* ctx = llama_new_context_with_model(model, params);
    return (llama_ctx_t)ctx;
}

void llama_wrapper_free_model(llama_ctx_t ctx_ptr) {
    struct llama_context* ctx = (struct llama_context*)ctx_ptr;
    if (ctx) llama_free(ctx);
}

const char* llama_generate_advanced(
    llama_ctx_t ctx_ptr,
    const char* prompt,
    unsigned int max_tokens,
    unsigned int top_k,
    double top_p,
    double temperature,
    double repeat_penalty,
    unsigned int seed
) {
    std::lock_guard<std::mutex> lock(output_mutex);
    struct llama_context* ctx = (struct llama_context*)ctx_ptr;
    if (!ctx) {
        OutputDebugStringA("[llama_generate_advanced] Model not loaded.\n");
        return "Model not loaded.";
    }
    const struct llama_model* model = llama_get_model(ctx);
    if (!model) {
        OutputDebugStringA("[llama_generate_advanced] Model not loaded (no model).\n");
        return "Model not loaded (no model).";
    }
    const struct llama_vocab* vocab = llama_model_get_vocab(model);
    if (!vocab) {
        OutputDebugStringA("[llama_generate_advanced] Model not loaded (no vocab).\n");
        return "Model not loaded (no vocab).";
    }
    // Device-aware context size optimization
    MEMORYSTATUSEX statex;
    statex.dwLength = sizeof(statex);
    GlobalMemoryStatusEx(&statex);
    DWORDLONG totalPhys = statex.ullTotalPhys;
    unsigned int optimal_ctx = 512;
    if (totalPhys > (DWORDLONG)16 * 1024 * 1024 * 1024) optimal_ctx = 4096;
    else if (totalPhys > (DWORDLONG)8 * 1024 * 1024 * 1024) optimal_ctx = 2048;
    else if (totalPhys > (DWORDLONG)4 * 1024 * 1024 * 1024) optimal_ctx = 1024;
    OutputDebugStringA((std::string("[llama_generate_advanced] Detected RAM: ") + std::to_string(totalPhys) + ", using ctx: " + std::to_string(optimal_ctx) + "\n").c_str());
    // Tokenize prompt using vocab
    std::vector<llama_token> tokens_prompt(4096);
    int n_prompt_tokens = llama_tokenize(vocab, prompt, (int)strlen(prompt), tokens_prompt.data(), (int)tokens_prompt.size(), true, false);
    if (n_prompt_tokens < 0) {
        OutputDebugStringA("[llama_generate_advanced] Tokenization failed.\n");
        return "Tokenization failed.";
    }
    tokens_prompt.resize(n_prompt_tokens);
    OutputDebugStringA((std::string("[llama_generate_advanced] Tokenized prompt, tokens: ") + std::to_string(n_prompt_tokens) + "\n").c_str());
    // Evaluate prompt
    llama_batch batch = llama_batch_get_one(tokens_prompt.data(), n_prompt_tokens);
    if (llama_decode(ctx, batch) < 0) {
        OutputDebugStringA("[llama_generate_advanced] Prompt evaluation failed.\n");
        return "Prompt evaluation failed.";
    }
    llama_batch_free(batch);
    OutputDebugStringA("[llama_generate_advanced] Prompt evaluated.\n");
    // Generation loop with advanced sampling
    std::vector<llama_token> output_tokens;
    std::vector<llama_token> recent_tokens;
    recent_tokens.reserve(64);
    std::mt19937 rng(seed ? seed : std::random_device{}());
    int n_vocab = llama_vocab_n_tokens(vocab);
    for (unsigned int i = 0; i < max_tokens; ++i) {
        float* logits = llama_get_logits(ctx);
        // Apply repeat penalty
        for (size_t j = 0; j < recent_tokens.size(); ++j) {
            llama_token t = recent_tokens[j];
            if (t >= 0 && t < n_vocab) logits[t] *= repeat_penalty;
        }
        // Top-k, top-p, temperature sampling
        std::vector<std::pair<float, llama_token>> logits_id;
        logits_id.reserve(n_vocab);
        for (int token_id = 0; token_id < n_vocab; ++token_id) {
            logits_id.emplace_back(logits[token_id], token_id);
        }
        // Top-k
        if (top_k > 0 && top_k < (unsigned int)logits_id.size()) {
            std::partial_sort(logits_id.begin(), logits_id.begin() + top_k, logits_id.end(), std::greater<>());
            logits_id.resize(top_k);
        }
        // Top-p
        if (top_p < 1.0) {
            std::sort(logits_id.begin(), logits_id.end(), std::greater<>());
            float cum_prob = 0.0f;
            float sum = 0.0f;
            for (const auto& p : logits_id) sum += std::exp(p.first / temperature);
            std::vector<std::pair<float, llama_token>> filtered;
            for (const auto& p : logits_id) {
                float prob = std::exp(p.first / temperature) / sum;
                cum_prob += prob;
                filtered.push_back(p);
                if (cum_prob >= top_p) break;
            }
            logits_id = std::move(filtered);
        }
        // Softmax and sample
        std::vector<float> probs;
        probs.reserve(logits_id.size());
        float sum = 0.0f;
        for (const auto& p : logits_id) {
            float prob = std::exp(p.first / temperature);
            probs.push_back(prob);
            sum += prob;
        }
        for (float& p : probs) p /= sum;
        std::discrete_distribution<> dist(probs.begin(), probs.end());
        llama_token next_token = logits_id[dist(rng)].second;
        output_tokens.push_back(next_token);
        recent_tokens.push_back(next_token);
        if (recent_tokens.size() > 64) recent_tokens.erase(recent_tokens.begin());
        // Prepare batch for next token
        llama_batch next_batch = llama_batch_get_one(&next_token, 1);
        if (llama_decode(ctx, next_batch) < 0) {
            llama_batch_free(next_batch);
            OutputDebugStringA("[llama_generate_advanced] Decoding failed.\n");
            break;
        }
        llama_batch_free(next_batch);
        // Stop if EOS
        if (next_token == llama_vocab_eos(vocab)) {
            OutputDebugStringA("[llama_generate_advanced] EOS token reached.\n");
            break;
        }
        if (i % 10 == 0) OutputDebugStringA((std::string("[llama_generate_advanced] Generated token ") + std::to_string(i) + "\n").c_str());
    }
    // Detokenize output
    std::vector<char> output_text(4096);
    int n_chars = llama_detokenize(vocab, output_tokens.data(), (int)output_tokens.size(), output_text.data(), (int)output_text.size(), true, false);
    if (n_chars < 0) {
        OutputDebugStringA("[llama_generate_advanced] Detokenization failed.\n");
        return "Detokenization failed.";
    }
    last_output = std::string(output_text.data(), n_chars);
    OutputDebugStringA("[llama_generate_advanced] Generation complete.\n");
    if (last_output.empty()) {
        return "";
    }
    return last_output.c_str();
}
