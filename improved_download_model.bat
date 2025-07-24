@echo off
rem Simple batch file for downloading Qwen2.5:7b model for Neonote
rem Updated to use a working Hugging Face repository with exact filename

echo ===================================================
echo Qwen2.5:7b Model Downloader for Neonote
echo ===================================================
echo.

rem Set variables
set OUTPUT_DIR=%USERPROFILE%\Desktop\neonote_model_output
set NEONOTE_DIR=%USERPROFILE%\Desktop\notion_offline
set NEONOTE_MODEL_DIR=%NEONOTE_DIR%\assets\ai_model
set MODEL_FILENAME=qwen2.5-7b-gguf-q4_0.bin

rem Create output directory
echo Creating output directory...
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

rem Create Neonote model directory
echo Creating Neonote model directory...
if not exist "%NEONOTE_DIR%" mkdir "%NEONOTE_DIR%"
if not exist "%NEONOTE_MODEL_DIR%" mkdir "%NEONOTE_MODEL_DIR%"

echo.
echo ===================================================
echo IMPORTANT: Manual Download Required
echo ===================================================
echo.
echo Due to Hugging Face authentication requirements, please:
echo.
echo 1. Visit: https://huggingface.co/QuantFactory/Qwen2.5-7B-GGUF
echo 2. Sign in or create a free Hugging Face account
echo 3. Download one of these files (in order of preference):
echo    - qwen2.5-7b-Q4_0.gguf (recommended)
echo    - qwen2.5-7b-Q4_K_M.gguf
echo    - Any other Q4 or Q5 quantized version
echo 4. Save it to: %OUTPUT_DIR%
echo 5. Press any key after the download completes
echo.
echo This script will then copy the model to the correct location.
echo.
pause

rem Check for any of the possible model files
set MODEL_FOUND=false
set MODEL_PATH=

if exist "%OUTPUT_DIR%\qwen2.5-7b-q4_0.gguf" (
    set MODEL_FOUND=true
    set MODEL_PATH=%OUTPUT_DIR%\qwen2.5-7b-q4_0.gguf
) else if exist "%OUTPUT_DIR%\qwen2.5-7b-Q4_0.gguf" (
    set MODEL_FOUND=true
    set MODEL_PATH=%OUTPUT_DIR%\qwen2.5-7b-Q4_0.gguf
) else if exist "%OUTPUT_DIR%\qwen2.5-7b-Q4_K_M.gguf" (
    set MODEL_FOUND=true
    set MODEL_PATH=%OUTPUT_DIR%\qwen2.5-7b-Q4_K_M.gguf
) else (
    rem Try to find any gguf file
    for %%f in ("%OUTPUT_DIR%\*.gguf") do (
        set MODEL_FOUND=true
        set MODEL_PATH=%%f
        goto :found_model
    )
)

:found_model
if "%MODEL_FOUND%"=="false" (
    echo.
    echo No model file found in %OUTPUT_DIR%
    echo Please download a Qwen2.5-7B GGUF file and try again.
    goto :end
)

rem Copy model to Neonote app
echo.
echo Found model file: %MODEL_PATH%
echo Copying model to Neonote app...
copy "%MODEL_PATH%" "%NEONOTE_MODEL_DIR%\%MODEL_FILENAME%"

echo.
echo ===================================================
echo Model installation complete.
echo ===================================================
echo.
echo The optimized Qwen2.5:7b model has been installed at:
echo %NEONOTE_MODEL_DIR%\%MODEL_FILENAME%
echo.
echo You can now run the Neonote app, and the AI assistant
echo will automatically use this optimized model.
echo.

:end
echo Press any key to exit...
pause >nul
