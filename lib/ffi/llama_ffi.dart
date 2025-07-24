import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

// FFI signatures for llama.cpp wrapper
typedef LlamaLoadModelNative = ffi.Pointer<ffi.Void> Function(ffi.Pointer<Utf8>);
typedef LlamaFreeModelNative = ffi.Void Function(ffi.Pointer<ffi.Void>);
typedef LlamaGenerateNative = ffi.Pointer<Utf8> Function(ffi.Pointer<ffi.Void>, ffi.Pointer<Utf8>, ffi.Uint32, ffi.Uint32, ffi.Double, ffi.Double, ffi.Double, ffi.Uint32);

typedef LlamaLoadModel = ffi.Pointer<ffi.Void> Function(ffi.Pointer<Utf8>);
typedef LlamaFreeModel = void Function(ffi.Pointer<ffi.Void>);
typedef LlamaGenerate = ffi.Pointer<Utf8> Function(ffi.Pointer<ffi.Void>, ffi.Pointer<Utf8>, int, int, double, double, double, int);

class LlamaCpp {
  late ffi.DynamicLibrary _lib;
  late ffi.Pointer<ffi.Void> _ctx;
  late LlamaGenerate _generate;
  late LlamaFreeModel _freeModel;

  LlamaCpp(String modelPath) {
    if (Platform.isWindows) {
      // Try loading from assets/ai_model first, then fallback to current directory
      final dllPaths = [
        'assets/ai_model/llama_wrapper.dll',
        'llama_wrapper.dll'
      ];
      ffi.DynamicLibrary? lib;
      for (final p in dllPaths) {
        try {
          lib = ffi.DynamicLibrary.open(p);
          break;
        } catch (e) {
          // Continue to next path
        }
      }
      if (lib == null) {
        throw Exception('llama_wrapper.dll not found in assets/ai_model or current directory');
      }
      _lib = lib;
    } else if (Platform.isLinux) {
      _lib = ffi.DynamicLibrary.open('libllama_wrapper.so');
    } else if (Platform.isMacOS) {
      _lib = ffi.DynamicLibrary.open('libllama_wrapper.dylib');
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    final loadModel = _lib.lookupFunction<LlamaLoadModelNative, LlamaLoadModel>('llama_load_model');
    _generate = _lib.lookupFunction<LlamaGenerateNative, LlamaGenerate>('llama_generate_advanced');
    _freeModel = _lib.lookupFunction<LlamaFreeModelNative, LlamaFreeModel>('llama_wrapper_free_model');

    final modelPathPtr = modelPath.toNativeUtf8();
    _ctx = loadModel(modelPathPtr);
    calloc.free(modelPathPtr);
  }

  String generate(
    String prompt, {
    int maxTokens = 256,
    int topK = 40,
    double topP = 0.95,
    double temperature = 0.8,
    double repeatPenalty = 1.1,
    int seed = 42,
  }) {
    final promptPtr = prompt.toNativeUtf8();
    final resultPtr = _generate(
      _ctx,
      promptPtr,
      maxTokens,
      topK,
      topP,
      temperature,
      repeatPenalty,
      seed,
    );
    final result = resultPtr.toDartString();
    calloc.free(promptPtr);
    // Do not free resultPtr if it's static or managed by C
    return result;
  }

  void dispose() {
    _freeModel(_ctx);
  }
}
