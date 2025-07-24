import 'package:flutter/material.dart';
import 'widgets/ai_chat_panel.dart';
import '../ffi/llama_ffi.dart';

/// Dedicated screen for AI chat
class AIChatScreen extends StatelessWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  static final LlamaCpp _llama = LlamaCpp('assets/ai_model/Qwen2-VL-2B-Instruct-Q4_K_M.gguf');

  Future<String> _sendMessageToLocalModel(String message) async {
    // Call the local model via FFI
    try {
      final response = await Future(() => _llama.generate(message));
      return response;
    } catch (e) {
      return 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AIChatPanel(
          onSendMessage: _sendMessageToLocalModel,
        ),
      ),
    );
  }
}
