# Neonote Project Structure

## Overview
This document outlines the project structure for the Neonote application, a cross-platform Notion clone built with Flutter and optional Tauri/Rust components. The structure is designed to support modular development, clear separation of concerns, and future extensibility.

## Root Directory Structure
```
neonote/
├── .github/                    # GitHub Actions workflows for CI/CD
├── assets/                     # Static assets (icons, fonts, images)
├── lib/                        # Flutter application code
├── test/                       # Test files
├── integration_test/           # Flutter integration tests
├── tauri/                      # Optional Tauri/Rust backend (desktop only)
├── android/                    # Android platform-specific code
├── ios/                        # iOS platform-specific code
├── macos/                      # macOS platform-specific code
├── linux/                      # Linux platform-specific code
├── windows/                    # Windows platform-specific code
├── web/                        # Web platform-specific code (optional)
├── example_pages/              # Example pages demonstrating all features
├── pubspec.yaml                # Flutter dependencies
├── README.md                   # Project documentation
└── LICENSE                     # Project license
```

## Flutter Application Structure (lib/)
```
lib/
├── main.dart                   # Application entry point
├── app.dart                    # App widget and initialization
├── config/                     # Configuration files
│   ├── constants.dart          # App-wide constants
│   ├── themes.dart             # Theme definitions
│   └── routes.dart             # Route definitions
├── models/                     # Data models
│   ├── blocks/                 # Block type definitions
│   │   ├── base_block.dart     # Base block class
│   │   ├── text_blocks.dart    # Text-based blocks
│   │   ├── list_blocks.dart    # List-based blocks
│   │   ├── layout_blocks.dart  # Layout blocks
│   │   ├── database_blocks.dart # Database blocks
│   │   ├── media_blocks.dart   # Media and embed blocks
│   │   ├── advanced_blocks.dart # Advanced blocks
│   │   └── special_blocks.dart # Special blocks (code, equation)
│   ├── page.dart               # Page model
│   ├── workspace.dart          # Workspace model
│   ├── user_settings.dart      # User settings model
│   └── api_key.dart            # API key model
├── storage/                    # Storage and persistence
│   ├── repository.dart         # Repository interface
│   ├── file_repository.dart    # File-based repository
│   ├── sqlite_repository.dart  # SQLite repository
│   ├── git_manager.dart        # Git version control
│   ├── search_index.dart       # Full-text search indexing
│   └── embeddings_store.dart   # Vector embeddings storage
├── ui/                         # UI components
│   ├── screens/                # Full screens
│   │   ├── home_screen.dart    # Home/workspace screen
│   │   ├── editor_screen.dart  # Page editor screen
│   │   ├── settings_screen.dart # Settings screen
│   │   └── search_screen.dart  # Search screen
│   ├── blocks/                 # Block-specific widgets
│   │   ├── block_factory.dart  # Factory for creating block widgets
│   │   ├── text_blocks/        # Text block widgets
│   │   ├── list_blocks/        # List block widgets
│   │   ├── layout_blocks/      # Layout block widgets
│   │   ├── database_blocks/    # Database block widgets
│   │   ├── media_blocks/       # Media block widgets
│   │   ├── advanced_blocks/    # Advanced block widgets
│   │   └── special_blocks/     # Special block widgets
│   ├── editor/                 # Editor components
│   │   ├── editor.dart         # Main editor widget
│   │   ├── toolbar.dart        # Editing toolbar
│   │   ├── block_menu.dart     # Block insertion menu
│   │   └── drag_handle.dart    # Block drag handle
│   ├── common/                 # Common UI components
│   │   ├── app_bar.dart        # Custom app bar
│   │   ├── sidebar.dart        # Navigation sidebar
│   │   ├── loading.dart        # Loading indicators
│   │   └── dialogs.dart        # Common dialogs
│   ├── ai/                     # AI assistant UI
│   │   ├── chat_interface.dart # AI chat interface
│   │   ├── voice_interface.dart # Voice interaction UI
│   │   └── suggestion_panel.dart # AI suggestions panel
│   └── graph/                  # Graph view UI
│       ├── graph_view.dart     # Main graph visualization
│       ├── node_renderer.dart  # Graph node renderer
│       └── controls.dart       # Graph controls
├── md/                         # Markdown processing
│   ├── parser.dart             # Markdown parser
│   ├── renderer.dart           # Markdown renderer
│   ├── exporter.dart           # Markdown exporter
│   └── frontmatter.dart        # YAML frontmatter handling
├── ai/                         # AI functionality
│   ├── llm_interface.dart      # LLM interface
│   ├── qwen_model.dart         # Qwen2.5 model integration
│   ├── embeddings.dart         # Embedding generation
│   ├── rag.dart                # Retrieval-augmented generation
│   ├── voice_recognition.dart  # Voice recognition
│   └── text_to_speech.dart     # Text-to-speech
├── graph/                      # Graph functionality
│   ├── graph_builder.dart      # Graph data structure builder
│   ├── layout_engine.dart      # Force-directed layout engine
│   └── filters.dart            # Graph filtering
├── plugins/                    # Plugin system
│   ├── plugin_manager.dart     # Plugin management
│   ├── js_runtime.dart         # JavaScript runtime
│   └── extension_points.dart   # Extension points
├── services/                   # Services
│   ├── notion_api.dart         # Notion API integration
│   ├── search_service.dart     # Search service
│   ├── notification_service.dart # Notification service
│   ├── widget_service.dart     # Widget service
│   └── export_service.dart     # Export service
├── utils/                      # Utilities
│   ├── file_utils.dart         # File utilities
│   ├── string_utils.dart       # String utilities
│   ├── date_utils.dart         # Date utilities
│   └── platform_utils.dart     # Platform-specific utilities
└── widgets/                    # Platform widgets
    ├── home_widget.dart        # Home screen widget
    └── ai_widget.dart          # AI assistant widget
```

## Tauri/Rust Backend Structure (tauri/)
```
tauri/
├── src/                        # Rust source code
│   ├── main.rs                 # Tauri application entry point
│   ├── commands.rs             # Tauri command definitions
│   ├── sqlite_watcher.rs       # SQLite database watcher
│   ├── file_watcher.rs         # File system watcher
│   └── ai/                     # AI-related Rust code
│       ├── model_loader.rs     # GGUF model loader
│       ├── inference.rs        # Model inference
│       └── embeddings.rs       # Embedding generation
├── src-tauri/                  # Tauri configuration
│   ├── tauri.conf.json         # Tauri configuration
│   ├── Cargo.toml              # Rust dependencies
│   └── build.rs                # Build script
└── Cargo.toml                  # Workspace Cargo.toml
```

## Assets Structure
```
assets/
├── fonts/                      # Application fonts
├── icons/                      # Application icons
│   ├── app_icon.png            # Main application icon
│   └── notification_icon.png   # Notification icon
├── images/                     # Static images
├── models/                     # AI model files
│   └── qwen2.5-7b-q4_0.gguf    # Quantized Qwen2.5 model
└── sounds/                     # Sound effects
```

## Platform-Specific Directories
Each platform-specific directory contains the necessary configuration and native code for that platform:

- **android/**: Android-specific configuration and native code
- **ios/**: iOS-specific configuration and native code
- **macos/**: macOS-specific configuration and native code
- **linux/**: Linux-specific configuration and native code
- **windows/**: Windows-specific configuration and native code

## CI/CD Structure (.github/workflows/)
```
.github/workflows/
├── flutter_test.yml            # Flutter tests workflow
├── build_android.yml           # Android build workflow
├── build_ios.yml               # iOS build workflow
├── build_macos.yml             # macOS build workflow
├── build_linux.yml             # Linux build workflow
├── build_windows.yml           # Windows build workflow
└── release.yml                 # Release workflow
```

## Example Pages Structure
```
example_pages/
├── basic_formatting/           # Basic text formatting examples
├── advanced_blocks/            # Advanced block type examples
├── databases/                  # Database examples
├── media_embeds/               # Media and embed examples
└── templates/                  # Template examples
```

## Key Design Considerations

1. **Modularity**: The structure separates concerns into distinct modules, making the codebase easier to maintain and extend.

2. **Block System**: All block types are defined in the `models/blocks/` directory and have corresponding UI components in `ui/blocks/`.

3. **Storage Layer**: The storage system is abstracted through repositories, allowing for different storage backends (file-based, SQLite).

4. **AI Integration**: The AI functionality is isolated in the `ai/` directory, with UI components in `ui/ai/`.

5. **Cross-Platform**: The structure supports all target platforms while minimizing platform-specific code.

6. **Testing**: Test directories mirror the structure of the main codebase for comprehensive test coverage.

7. **Documentation**: Example pages and README provide clear documentation for users and developers.

8. **Extensibility**: The plugin system allows for future extensions without modifying the core codebase.

This structure provides a solid foundation for implementing all the required features of Neonote while maintaining code quality and extensibility.
