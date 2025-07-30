import 'dart:io';
import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../ffi/llama_bindings.dart';
import '../ai/llm_interface.dart';

class AIService implements LLMInterface {
  static final AIService _instance = AIService._internal();

  factory AIService() => _instance;

  AIService._internal();

  // FFI bindings
  late LlamaBindings _bindings;
  Pointer<LlamaContext> _context = nullptr;
  Pointer<LlamaModel> _model = nullptr;

  // Initialization status
  bool _isInitialized = false;

  // Get initialization status
  bool get isInitialized => _isInitialized;

  // Initialize AI service
  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Load native library
      final libraryPath = await _getLibraryPath();
      if (libraryPath == null) {
        debugPrint('Failed to locate native library');
        return false;
      }

      // Initialize bindings
      _bindings = LlamaBindings(DynamicLibrary.open(libraryPath));

      // Set log level
      _bindings.llama_log_set(LLAMA_LOG_LEVEL_WARN);

      // Load model
      await _loadModel();

      _isInitialized = _model != nullptr && _context != nullptr;
      debugPrint('AI service initialized successfully: $_isInitialized');
      return _isInitialized;
    } catch (e) {
      debugPrint('Failed to initialize AI service: $e');
      return false;
    }
  }

  // Get library path based on platform
  Future<String?> _getLibraryPath() async {
    if (kIsWeb) return null;

    if (Platform.isWindows) {
      return 'llama.dll';
    } else if (Platform.isLinux) {
      return 'libllama.so';
    } else if (Platform.isMacOS) {
      return 'libllama.dylib';
    } else if (Platform.isAndroid) {
      return 'libllama.so';
    } else if (Platform.isIOS) {
      return 'libllama.dylib';
    }

    return null;
  }

  // Load model
  Future<void> _loadModel() async {
    if (_model != nullptr) return;

    try {
      // Get model path
      final modelPath = await _getModelPath();
      if (modelPath == null) {
        debugPrint('Failed to locate model file');
        return;
      }

      // Create model params
      final params = _bindings.llama_model_default_params();

      // Load model
      final modelPathUtf8 = modelPath.toNativeUtf8();
      _model =
          _bindings.llama_load_model_from_file(modelPathUtf8.cast(), params);
      malloc.free(modelPathUtf8);

      if (_model == nullptr) {
        debugPrint('Failed to load model');
        return;
      }

      // Create context params
      final contextParams = _bindings.llama_context_default_params();
      contextParams.n_ctx = 4096; // Context length

      // Create context
      _context = _bindings.llama_new_context_with_model(_model, contextParams);

      if (_context == nullptr) {
        debugPrint('Failed to create context');
        _bindings.llama_free_model(_model);
        _model = nullptr;
        return;
      }

      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Failed to load model: $e');
    }
  }

  // Get model path
  Future<String?> _getModelPath() async {
    if (kIsWeb) return null;

    try {
      final appDir = await getApplicationSupportDirectory();
      final modelDir = Directory(path.join(appDir.path, 'assets', 'ai_model'));

      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      final modelPath =
          path.join(modelDir.path, 'Qwen2-VL-2B-Instruct-Q4_K_M.gguf');
      final modelFile = File(modelPath);

      if (await modelFile.exists()) {
        return modelPath;
      }

      // Check for alternative model files if the exact name isn't found
      final files = await modelDir.list().toList();
      for (final file in files) {
        if (file is File && file.path.endsWith('.gguf')) {
          debugPrint('Using alternative model file: ${file.path}');
          return file.path;
        }
      }

      debugPrint('Model file not found');
      return null;
    } catch (e) {
      debugPrint('Error locating model file: $e');
      return null;
    }
  }

  // Generate text
  @override
  Future<String> generateText(
    String prompt, {
    int maxTokens = 512,
    double temperature = 0.7,
    double topP = 0.9,
    int seed = 42,
    void Function(String)? onToken,
  }) async {
    if (!_isInitialized || _context == nullptr) {
      await initialize();
      if (!_isInitialized || _context == nullptr) {
        return 'AI service is not initialized properly';
      }
    }

    try {
      // Prepare prompt
      final promptUtf8 = prompt.toNativeUtf8();

      // Tokenize prompt
      final tokensCapacity = prompt.length + maxTokens;
      final tokens = calloc<Int32>(tokensCapacity);
      final nTokens = _bindings.llama_tokenize(
        _model,
        promptUtf8.cast(),
        promptUtf8.length,
        tokens,
        tokensCapacity,
        true,
        false,
      );

      if (nTokens < 0) {
        malloc.free(promptUtf8);
        calloc.free(tokens);
        return 'Failed to tokenize prompt';
      }

      // Evaluate prompt
      _bindings.llama_eval(_context, tokens.cast(), nTokens, 0, 1);

      // Generate response
      final result = StringBuffer();
      final samplingParams = _bindings.llama_sampling_params_default();
      samplingParams.temp = temperature;
      samplingParams.top_p = topP;
      samplingParams.n_prev = nTokens;
      samplingParams.n_probs = 0;

      final state = _bindings.llama_sampling_init(samplingParams);

      for (var i = 0; i < maxTokens; i++) {
        // Sample token
        final token =
            _bindings.llama_sampling_sample(state, _context, nullptr.cast());

        // Check for end of generation
        if (token == _bindings.llama_token_eos(_model)) {
          break;
        }

        // Get token text
        final tokenText = _bindings.llama_token_to_piece(_context, token);
        if (tokenText == nullptr) {
          continue;
        }

        final text = tokenText.cast<Utf8>().toDartString();
        result.write(text);

        // Call token callback if provided
        onToken?.call(text);

        // Evaluate token
        final nextToken = calloc<Int32>(1);
        nextToken.value = token;
        _bindings.llama_eval(_context, nextToken, 1, nTokens + i, 1);
        calloc.free(nextToken);
      }

      // Clean up
      _bindings.llama_sampling_free(state);
      malloc.free(promptUtf8);
      calloc.free(tokens);

      return result.toString();
    } catch (e) {
      debugPrint('Error generating text: $e');
      return 'Error generating text: $e';
    }
  }

  // Generate text with image
  @override
  Future<String> generateTextWithImage(
    String prompt,
    List<int> imageData, {
    int maxTokens = 512,
    double temperature = 0.7,
    double topP = 0.9,
    int seed = 42,
    void Function(String)? onToken,
  }) async {
    if (!_isInitialized || _context == nullptr) {
      await initialize();
      if (!_isInitialized || _context == nullptr) {
        return 'AI service is not initialized properly';
      }
    }

    try {
      // Generate text with the image context
      final result = await generateText(
        prompt,
        maxTokens: maxTokens,
        temperature: temperature,
        topP: topP,
        seed: seed,
        onToken: onToken,
      );

      return result;
    } catch (e) {
      debugPrint('Error generating text with image: $e');
      return 'Error generating text with image: $e';
    }
  }

  // Clean up resources
  @override
  void dispose() {
    if (_context != nullptr) {
      _bindings.llama_free(_context);
      _context = nullptr;
    }

    if (_model != nullptr) {
      _bindings.llama_free_model(_model);
      _model = nullptr;
    }

    _isInitialized = false;
  }
}
