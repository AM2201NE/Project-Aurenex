import 'package:flutter/material.dart';

/// Interface for LLM (Large Language Model) implementations
abstract class LLMInterface {
  /// Initialize the model
  Future<bool> initialize();
  
  /// Generate text based on a prompt
  Future<String> generateText(String prompt, {
    int maxTokens = 512,
    double temperature = 0.7,
    double topP = 0.9,
    int seed = 42,
    void Function(String)? onToken,
  });
  
  /// Generate text with image input
  Future<String> generateTextWithImage(String prompt, List<int> imageData, {
    int maxTokens = 512,
    double temperature = 0.7,
    double topP = 0.9,
    int seed = 42,
    void Function(String)? onToken,
  });
  
  /// Clean up resources
  void dispose();
}
