# Neonote Project Structure

This document provides an overview of the Neonote project structure and key components.

## Directory Structure

```
neonote/
├── assets/
│   ├── ai_model/      # AI model files (place Qwen2-VL-2B-Instruct-Q4_K_M.gguf here)
│   ├── fonts/         # Font files
│   └── images/        # Image assets
├── docs/
│   └── windows_integration_guide.md  # Guide for Windows integration
└── lib/
    ├── ai/            # AI-related interfaces and utilities
    ├── customization/ # Theme and customization options
    ├── design/        # Design system components
    ├── ffi/           # Foreign Function Interface for llama.cpp
    ├── graph/         # Graph view implementation
    ├── md/            # Markdown parsing and rendering
    ├── models/        # Data models
    ├── platform/      # Platform-specific configurations
    ├── screens/       # App screens
    ├── services/      # Core services
    ├── utils/         # Utility functions and helpers
    ├── widgets/       # Reusable UI components
    └── main.dart      # App entry point
```

## Key Components

### AI Integration
- `lib/ffi/llama_bindings.dart`: FFI bindings for llama.cpp
- `lib/services/ai_service.dart`: AI service implementation
- `lib/ai/llm_interface.dart`: Interface for language model interactions

### Core Features
- `lib/models/`: Data models for pages, blocks, and workspaces
- `lib/services/storage_service.dart`: Database and file storage
- `lib/md/markdown_parser.dart`: Markdown import/export

### UI Components
- `lib/screens/`: Main application screens
- `lib/widgets/`: Reusable UI components
- `lib/graph/graph_view.dart`: Graph visualization

### Platform Support
- `lib/platform/windows_config.dart`: Windows-specific configuration
- `lib/utils/file_picker_helper.dart`: Cross-platform file picking

## Getting Started

1. Place the AI model file in `assets/ai_model/`
2. Run `flutter pub get` to install dependencies
3. Follow the Windows integration guide in `docs/`
