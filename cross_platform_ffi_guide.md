# Neonote: Cross-Platform llama.cpp FFI Integration Guide

This guide provides detailed instructions for compiling the `llama.cpp` native library and integrating it with the Neonote Flutter application using Dart FFI (Foreign Function Interface) across different platforms (Linux, Windows, macOS, Android, iOS). The goal is to enable local AI inference using the Qwen2.5-VL-2B-Instruct model.

**Author:** Manus AI
**Date:** June 3, 2025

## 1. Overview

The Neonote application utilizes the `llama.cpp` library for efficient local language model inference. To achieve this, the native `llama.cpp` code must be compiled into a dynamic library (`.so`, `.dll`, `.dylib`) or static library/framework specific to each target platform and architecture. Flutter's FFI mechanism is then used to load this library and call its functions from the Dart code (`lib/services/ai_service.dart` via `lib/ffi/llama_bindings.dart`).

This package already includes:

*   The compiled `libllama.so` for **Linux (x86_64)** located at `/home/ubuntu/llama.cpp/build/bin/libllama.so` (within the build environment where this package was created).
*   Dart FFI bindings (`lib/ffi/llama_bindings.dart`) defining the necessary C function signatures.
*   The `AIService` (`lib/services/ai_service.dart`) which loads the library dynamically and calls the FFI functions.

You will need to compile the library for other target platforms by following the steps below.

## 2. Prerequisites

Ensure you have the necessary development tools installed for each target platform.

*   **General:**
    *   Git
    *   CMake (version 3.13+ recommended)
    *   A C/C++ compiler toolchain (GCC/Clang/MSVC)
*   **Linux (Debian/Ubuntu):**
    *   `sudo apt-get update && sudo apt-get install build-essential cmake git`
*   **Windows:**
    *   Visual Studio with C++ Desktop Development workload (includes MSVC compiler and CMake)
    *   Git for Windows
*   **macOS:**
    *   Xcode Command Line Tools (`xcode-select --install`)
    *   CMake (`brew install cmake`)
    *   Git (`brew install git`)
*   **Android:**
    *   Android NDK (installable via Android Studio SDK Manager)
    *   CMake (installable via Android Studio SDK Manager)
*   **iOS:**
    *   Xcode (latest version from App Store)
    *   CMake (`brew install cmake`)

## 3. Cloning llama.cpp

If you haven't already, clone the `llama.cpp` repository:

```bash
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
```

## 4. Compilation Instructions

Compile `llama.cpp` as a **shared library** for each platform. The output library needs to be placed where the Flutter application can find it during runtime.

A common convention is to place platform-specific libraries within the Flutter project structure, often in `android/src/main/jniLibs/<ABI>`, `ios/Frameworks`, or a dedicated `native/libs/<platform>` directory, and configure the build system (Gradle, Xcode) accordingly. The `AIService` currently attempts to load `libllama.so` from a fixed path (`/home/ubuntu/...`) which **must be updated** in `lib/ffi/llama_bindings.dart` (`loadLlamaLibrary` function) to dynamically locate the library based on the operating system.

### 4.1. Linux (x86_64)

This was compiled in the development environment. If you need to recompile:

```bash
mkdir build
cd build
cmake .. -DBUILD_SHARED_LIBS=ON -DLLAMA_CURL=OFF # Add other flags like -DLLAMA_OPENBLAS=ON if needed
make -j$(nproc)
```

*   **Output:** `build/bin/libllama.so`
*   **Placement:** Copy `libllama.so` to a suitable location within your Flutter project's Linux build resources or bundle it appropriately.

### 4.2. Windows (x86_64)

Use the Developer Command Prompt for Visual Studio or Git Bash.

```bash
mkdir build
cd build
# Use CMake generator for Visual Studio (e.g., "Visual Studio 17 2022")
# Adjust generator based on your VS version
cmake .. -G "Visual Studio 17 2022" -A x64 -DBUILD_SHARED_LIBS=ON -DLLAMA_CURL=OFF
cmake --build . --config Release
```

*   **Output:** `build\bin\Release\llama.dll`
*   **Placement:** Copy `llama.dll` to a location accessible by your Flutter app's Windows executable (e.g., alongside the `.exe` or in a directory included in the PATH).

### 4.3. macOS (x86_64 / arm64)

```bash
mkdir build
cd build
# Optionally specify architecture: -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" for universal binary
cmake .. -DBUILD_SHARED_LIBS=ON -DLLAMA_CURL=OFF -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 # Set appropriate deployment target
make -j$(sysctl -n hw.ncpu)
```

*   **Output:** `build/bin/libllama.dylib`
*   **Placement:** Copy `libllama.dylib` into the Flutter app's macOS bundle (e.g., within the `Frameworks` directory using Xcode build phases).

### 4.4. Android (arm64-v8a, armeabi-v7a, x86_64)

Use the Android NDK toolchain file.

```bash
# Repeat for each target ABI (e.g., arm64-v8a, armeabi-v7a, x86_64)
export ANDROID_NDK_HOME=/path/to/your/android/sdk/ndk/<version> # Set NDK path
export TARGET_ABI=arm64-v8a # Change this for other ABIs
export ANDROID_PLATFORM=android-21 # Minimum API level

mkdir build-$TARGET_ABI
cd build-$TARGET_ABI

cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
    -DANDROID_ABI=$TARGET_ABI \
    -DANDROID_PLATFORM=$ANDROID_PLATFORM \
    -DBUILD_SHARED_LIBS=ON \
    -DLLAMA_CURL=OFF \
    -DCMAKE_BUILD_TYPE=Release

make -j$(nproc)
cd ..
```

*   **Output:** `build-<ABI>/bin/libllama.so`
*   **Placement:** Copy each `libllama.so` into the corresponding ABI directory within your Flutter project: `android/app/src/main/jniLibs/<ABI>/libllama.so`.

### 4.5. iOS (arm64, simulator x86_64/arm64)

Compiling for iOS typically involves creating a static library or framework and linking it within Xcode.

```bash
mkdir build-ios
cd build-ios

# Configure for iOS device (arm64)
cmake .. -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0 \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLAMA_CURL=OFF \
    -DCMAKE_BUILD_TYPE=Release

# Build the static library
cmake --build . --config Release

# (Optional) Create an XCFramework combining device and simulator builds
# This requires building for simulator architectures as well and using xcodebuild
```

*   **Output:** `build-ios/bin/Release/libllama.a` (static library)
*   **Placement:** Integrate `libllama.a` and necessary headers into your Flutter project's iOS target using Xcode. You might need to wrap it in a Framework or configure linker flags.

## 5. Updating Library Loading in Dart

The `loadLlamaLibrary()` function in `lib/ffi/llama_bindings.dart` needs to be modified to correctly locate and load the compiled library based on the current operating system.

```dart
import 'dart:ffi';
import 'dart:io' show Platform;

DynamicLibrary loadLlamaLibrary() {
  if (Platform.isLinux) {
    // Adjust path based on where you place the library in your Linux build
    return DynamicLibrary.open('libllama.so'); // Or provide full path
  } else if (Platform.isWindows) {
    // Adjust path based on where you place the library in your Windows build
    return DynamicLibrary.open('llama.dll');
  } else if (Platform.isMacOS) {
    // Frameworks or relative path within the app bundle
    return DynamicLibrary.open('libllama.dylib');
  } else if (Platform.isAndroid) {
    // Android loads libraries packaged in jniLibs automatically
    return DynamicLibrary.open('libllama.so');
  } else if (Platform.isIOS) {
    // iOS static linking means symbols are available directly
    return DynamicLibrary.process();
  } else {
    throw Exception('Unsupported platform: ${Platform.operatingSystem}');
  }
}
```

## 6. Model File

Ensure the actual AI model file (`qwen2-vl-2b-instruct-q4_k_m.bin`, obtained by running the `copy_qwen2_vl_model.bat` script using your downloaded `.gguf` file) is accessible to the application at runtime. The `AIService` currently looks for it in a specific path within the app's documents directory (`_findLocalModel` function). You may need to adjust this logic:

*   Bundle the model as a Flutter asset and extract it on first run.
*   Modify the `_findLocalModel` function to look in the correct location.

## 7. Testing and Debugging

*   **FFI Signature Mismatches:** Ensure the Dart function signatures in `llama_bindings.dart` exactly match the C function signatures in `llama.h` (considering data types, pointers, etc.).
*   **Linking Errors:** Verify that the compiled library is correctly placed and accessible at runtime.
*   **Architecture Mismatches:** Ensure the compiled library's architecture matches the target device/emulator (e.g., arm64 library for an arm64 Android device).
*   **Model Loading Errors:** Check that the model file path is correct and the model format is compatible with the compiled `llama.cpp` version.

This guide provides a comprehensive starting point. Specific build configurations and integration steps might require adjustments based on your project setup and the versions of `llama.cpp` and Flutter used.

