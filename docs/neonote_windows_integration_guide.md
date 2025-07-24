# Neonote Windows Integration Guide

This guide provides instructions for setting up and running the Neonote app on Windows with the llama.cpp integration.

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Windows 10 or higher
- Visual Studio 2019 or higher with C++ desktop development workload
- Git

## Setup Instructions

1. **Extract the project files**
   - Extract the `neonote_fixed_final.zip` file to your desired location

2. **Install dependencies**
   - Open a terminal in the project root directory
   - Run `flutter pub get` to install all dependencies

3. **Place the AI model file**
   - Create a directory at `assets/ai_model/` if it doesn't exist
   - Copy your `Qwen2-VL-2B-Instruct-Q4_K_M.gguf` model file to this directory
   - If you have a different model file, you may need to update the model name in `lib/services/ai_service.dart`

4. **Build the Windows app**
   - Run `flutter build windows` to build the Windows app
   - The build output will be in `build/windows/runner/Release/`

5. **Copy the llama.dll file**
   - Copy the `llama.dll` file to the `build/windows/runner/Release/` directory (next to the .exe file)
   - This is required for the AI functionality to work

## Running the App

1. **From the build directory**
   - Navigate to `build/windows/runner/Release/`
   - Run `neonote.exe`

2. **From Visual Studio**
   - Open the solution file in `windows/`
   - Set the build configuration to Release
   - Build and run the project

## Troubleshooting

If you encounter any issues:

1. **Database initialization errors**
   - Ensure you have the latest SQLite DLLs in your system PATH
   - Check that the app has write permissions to its data directory

2. **AI model loading errors**
   - Verify that the model file is correctly placed in the assets/ai_model/ directory
   - Check that llama.dll is in the same directory as the executable
   - Ensure the model file name matches what's expected in the code

3. **Plugin errors**
   - Run `flutter clean` and then `flutter pub get` to refresh plugin registrations
   - Ensure all required Visual C++ redistributables are installed

## Features

- **Note-taking with rich text formatting**
- **AI assistant with multimodal capabilities**
- **Graph view for visualizing connections between notes**
- **Markdown import/export**
- **Mermaid diagram support**
- **Git versioning for change tracking**
- **Customizable themes and settings**

## Additional Resources

- For more information on llama.cpp integration, see `lib/ffi/llama_bindings.dart`
- For AI service implementation details, see `lib/services/ai_service.dart`
- For storage service implementation, see `lib/services/storage_service.dart`
