import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// Log level constants for llama.cpp
const int LLAMA_LOG_LEVEL_ERROR = 2;
const int LLAMA_LOG_LEVEL_WARN = 3;
const int LLAMA_LOG_LEVEL_INFO = 4;

/// Opaque pointer to llama_model
abstract class LlamaModel extends Opaque {}

/// Opaque pointer to llama_context
abstract class LlamaContext extends Opaque {}

/// Opaque pointer to llama_sampling_context
abstract class LlamaSamplingContext extends Opaque {}

/// Model parameters
class LlamaModelParams extends Struct {
  @Int32()
  external int n_gpu_layers;

  @Int32()
  external int main_gpu;

  external Pointer<Float> tensor_split;

  @Int32()
  external int vocab_only;

  @Bool()
  external bool use_mmap;

  @Bool()
  external bool use_mlock;
}

/// Context parameters
class LlamaContextParams extends Struct {
  @Int32()
  external int seed;

  @Int32()
  external int n_ctx;

  @Int32()
  external int n_batch;

  @Int32()
  external int n_threads;

  @Int32()
  external int n_threads_batch;
}

/// Sampling parameters
class LlamaSamplingParams extends Struct {
  @Float()
  external double temp;

  @Float()
  external double top_p;

  @Int32()
  external int n_prev;

  @Int32()
  external int n_probs;

  @Int32()
  external int min_keep;

  @Int32()
  external int seed;
}

/// FFI bindings for llama.cpp
class LlamaBindings {
  final DynamicLibrary _lib;

  LlamaBindings(this._lib);

  /// Set log level
  void llama_log_set(int level) {
    final function =
        _lib.lookupFunction<Void Function(Int32), void Function(int)>(
            'llama_log_set');

    function(level);
  }

  /// Get default model parameters
  LlamaModelParams llama_model_default_params() {
    final function = _lib.lookupFunction<
        LlamaModelParams Function(),
        LlamaModelParams Function()>('llama_model_default_params');

    return function();
  }

  /// Load model from file
  Pointer<LlamaModel> llama_load_model_from_file(
      Pointer<Utf8> path, LlamaModelParams params) {
    final function = _lib.lookupFunction<
        Pointer<LlamaModel> Function(Pointer<Utf8>, LlamaModelParams),
        Pointer<LlamaModel> Function(Pointer<Utf8>,
            LlamaModelParams)>('llama_load_model_from_file');

    return function(path, params);
  }

  /// Free model
  void llama_free_model(Pointer<LlamaModel> model) {
    final function = _lib.lookupFunction<
        Void Function(Pointer<LlamaModel>),
        void Function(Pointer<LlamaModel>)>('llama_free_model');

    function(model);
  }

  /// Get default context parameters
  LlamaContextParams llama_context_default_params() {
    final function = _lib.lookupFunction<
        LlamaContextParams Function(),
        LlamaContextParams Function()>('llama_context_default_params');

    return function();
  }

  /// Create new context with model
  Pointer<LlamaContext> llama_new_context_with_model(
      Pointer<LlamaModel> model, LlamaContextParams params) {
    final function = _lib.lookupFunction<
        Pointer<LlamaContext> Function(
            Pointer<LlamaModel>, LlamaContextParams),
        Pointer<LlamaContext> Function(Pointer<LlamaModel>,
            LlamaContextParams)>('llama_new_context_with_model');

    return function(model, params);
  }

  /// Free context
  void llama_free(Pointer<LlamaContext> ctx) {
    final function = _lib.lookupFunction<
        Void Function(Pointer<LlamaContext>),
        void Function(Pointer<LlamaContext>)>('llama_free');

    function(ctx);
  }

  /// Tokenize text
  int llama_tokenize(
    Pointer<LlamaModel> model,
    Pointer<Utf8> text,
    int textLength,
    Pointer<Int32> tokens,
    int maxTokens,
    bool addBos,
    bool special,
  ) {
    final function = _lib.lookupFunction<
        Int32 Function(Pointer<LlamaModel>, Pointer<Utf8>, Int32,
            Pointer<Int32>, Int32, Bool, Bool),
        int Function(Pointer<LlamaModel>, Pointer<Utf8>, int, Pointer<Int32>,
            int, bool, bool)>('llama_tokenize');

    return function(
        model, text, textLength, tokens, maxTokens, addBos, special);
  }

  /// Evaluate tokens
  int llama_eval(
    Pointer<LlamaContext> ctx,
    Pointer<Int32> tokens,
    int numTokens,
    int pos,
    int threads,
  ) {
    final function = _lib.lookupFunction<
        Int32 Function(Pointer<LlamaContext>, Pointer<Int32>, Int32, Int32),
        int Function(
            Pointer<LlamaContext>, Pointer<Int32>, int, int)>('llama_eval_simple');

    return function(ctx, tokens, numTokens, pos);
  }

  /// Get token as string
  Pointer<Utf8> llama_token_to_piece(
    Pointer<LlamaContext> ctx,
    int token,
  ) {
    final function = _lib.lookupFunction<
        Pointer<Utf8> Function(Pointer<LlamaContext>, Int32),
        Pointer<Utf8> Function(
            Pointer<LlamaContext>, int)>('llama_token_to_piece');

    return function(ctx, token);
  }

  /// Get EOS token
  int llama_token_eos(Pointer<LlamaModel> model) {
    final function = _lib.lookupFunction<
        Int32 Function(Pointer<LlamaModel>),
        int Function(Pointer<LlamaModel>)>('llama_token_eos');

    return function(model);
  }

  /// Get default sampling parameters
  LlamaSamplingParams llama_sampling_params_default() {
    final function = _lib.lookupFunction<
        LlamaSamplingParams Function(),
        LlamaSamplingParams Function()>('llama_sampling_default_params');

    return function();
  }

  /// Initialize sampling
  Pointer<LlamaSamplingContext> llama_sampling_init(
      LlamaSamplingParams params) {
    final function = _lib.lookupFunction<
        Pointer<LlamaSamplingContext> Function(LlamaSamplingParams),
        Pointer<LlamaSamplingContext> Function(
            LlamaSamplingParams)>('llama_sampling_init');

    return function(params);
  }

  /// Sample token
  int llama_sampling_sample(
    Pointer<LlamaSamplingContext> ctx,
    Pointer<LlamaContext> llamaCtx,
    Pointer<Int32> candidates,
  ) {
    final function = _lib.lookupFunction<
        Int32 Function(Pointer<LlamaSamplingContext>, Pointer<LlamaContext>,
            Pointer<Int32>),
        int Function(Pointer<LlamaSamplingContext>, Pointer<LlamaContext>,
            Pointer<Int32>)>('llama_sampling_sample');

    return function(ctx, llamaCtx, candidates);
  }

  /// Free sampling context
  void llama_sampling_free(Pointer<LlamaSamplingContext> ctx) {
    final function = _lib.lookupFunction<
        Void Function(Pointer<LlamaSamplingContext>),
        void Function(Pointer<LlamaSamplingContext>)>('llama_sampling_free');

    function(ctx);
  }
}
