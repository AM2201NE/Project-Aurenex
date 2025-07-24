# Neonote AI Integration Guide

## Introduction

This guide explains how to integrate the Qwen2.5-VL-2B-Instruct model with your Neonote app. The new model offers multimodal capabilities (text + images), voice output, and improved performance on mobile devices.

## Model Specifications

- **Model Name:** Qwen2.5-VL-2B-Instruct
- **Parameters:** 2 billion
- **Quantization:** 4-bit Q4_K_M (GGUF)
- **Size:** ~0.986 GB
- **Peak RAM Usage:** ~2.0 GB during inference
- **Inference Speed:** ~13 tokens/sec on Snapdragon 870
- **Context Window:** 4,096 tokens (extended via in-app chunking)
- **Capabilities:** Multimodal input, summarization, coding assistance, instruction following, voice output

## Setup Instructions

### 1. Model File Placement

The model file should be named `qwen2-vl-2b-instruct-q4_k_m.bin` and placed in the `assets/ai_model` directory of your Neonote app.

You can use the provided `copy_qwen2_vl_model.bat` script to automatically copy and rename the model file from your Desktop:

1. Ensure the file `Qwen2-VL-2B-Instruct-Q4_K_M.gguf` is on your Desktop
2. Run the `copy_qwen2_vl_model.bat` script
3. The script will copy and rename the file to the correct location

### 2. Model Loading in Flutter

The Neonote app is configured to load the model from the assets directory. The model loading code has been updated to support multimodal input and the new model architecture.

```dart
// Example model loading code
final model = await QwenModel.fromAsset(
  'assets/ai_model/qwen2-vl-2b-instruct-q4_k_m.bin',
  contextSize: 4096,
  multimodal: true,
);
```

### 3. Multimodal Input

The model now supports both text and image inputs:

```dart
// Example multimodal input
final response = await model.generateText(
  prompt: "Describe this image in detail.",
  images: [File("path/to/image.jpg")],
  maxTokens: 500,
);
```

### 4. Voice Output

The model supports voice output using Flutter's TTS capabilities:

```dart
import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts flutterTts = FlutterTts();

Future<void> speak(String text) async {
  await flutterTts.setLanguage('en-US');
  await flutterTts.setSpeechRate(0.5);
  await flutterTts.speak(text);
}

// Use after generating text
speak(response);
```

### 5. Large Context Handling

The app implements in-app chunking to handle contexts up to 12K tokens:

```dart
// Example chunking implementation
final chunks = await chunkText(largeInput, chunkSize, overlap);
String contextSummary = '';
String combinedAnswer = '';

for (int i = 0; i < chunks.length; i++) {
  String prompt = contextSummary.isNotEmpty
    ? '$contextSummary\n\n${chunks[i]}'
    : chunks[i];
  final response = await model.generateText(prompt, maxTokens: 1024);
  combinedAnswer += response + '\n';
  
  // Summarize this chunk's response for next context
  contextSummary = await model.generateText(
    'Summarize the following in one paragraph for context continuation:\n$response',
    maxTokens: 200,
  );
}
```

## Troubleshooting

### Common Issues

1. **Model Not Found**: Ensure the model file is correctly placed in the `assets/ai_model` directory and named `qwen2-vl-2b-instruct-q4_k_m.bin`.

2. **Out of Memory**: If you encounter memory issues, try:
   - Reducing the chunk size in the chunking implementation
   - Closing other applications to free up memory
   - Restarting the app

3. **Slow Inference**: If inference is too slow:
   - Check if other applications are using CPU/GPU resources
   - Try reducing the context size
   - Consider using a more powerful device for better performance

### Support

For additional support or questions about the AI integration, please refer to the Neonote documentation or contact the development team.
