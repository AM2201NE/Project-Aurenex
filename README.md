# README.md

# Aurenex - AI-Powered Note-Taking App

Aurenex is a Flutter-based note-taking application with integrated AI capabilities, designed to work offline on desktop platforms.

## Features

- **Rich Text Editing**: Support for 35+ block types including paragraphs, headings, lists, code blocks, images, and more
- **AI Assistant**: Integrated Qwen2.5-VL-2B-Instruct multimodal AI model for text and image analysis
- **Graph View**: Visualize connections between your notes
- **Markdown Support**: Import and export notes in Markdown format
- **Git Versioning**: Track changes to your notes over time
- **Mermaid Diagrams**: Create and render diagrams directly in your notes
- **Customizable Themes**: Light and dark mode support with customizable options
- **Cross-Platform**: Works on Windows, macOS, and Linux

## Getting Started

1. Install Flutter SDK (3.0.0 or higher)
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Place the Qwen2.5-VL-2B-Instruct model file in `assets/ai_model/`
5. Run `flutter run` to start the app in debug mode

For detailed Windows setup instructions, see the [Windows Integration Guide](docs/windows_integration_guide.md).

## Project Structure

See the [Project Structure](docs/project_structure.md) document for an overview of the codebase organization.

## Requirements

- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- For Windows: Visual Studio 2019 or higher with C++ desktop development workload
- 2GB+ of disk space for the AI model

## License

This project is licensed under the MIT License - see the LICENSE file for details.
