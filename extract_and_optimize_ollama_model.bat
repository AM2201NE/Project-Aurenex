@echo off
rem Automated Qwen2.5:7b Model Extraction and Optimization Script for Windows
rem This batch file automates the process of extracting and optimizing the Qwen2.5:7b model from Ollama

echo ===================================================
echo Qwen2.5:7b Model Extraction and Optimization
echo ===================================================
echo.

rem Set variables
set OLLAMA_DIR=%USERPROFILE%\.ollama
set OUTPUT_DIR=%USERPROFILE%\Desktop\notion_offline\assets\ai_model
set TEMP_DIR=%USERPROFILE%\Desktop\qwen_temp
set SCRIPT_PATH=%~dp0extract_and_optimize_ollama_model.py

rem Check if Python is installed
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python is required but not found.
    echo Please install Python 3.8 or newer and try again.
    goto :error
)

rem Create output directory
echo Creating output directory...
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

rem Create temporary directory
echo Creating temporary directory...
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

rem Run the Python script
echo Running model extraction and optimization script...
python "%SCRIPT_PATH%" --ollama-dir "%OLLAMA_DIR%" --output-dir "%OUTPUT_DIR%" --temp-dir "%TEMP_DIR%"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Model extraction and optimization failed.
    goto :error
)

echo.
echo ===================================================
echo SUCCESS! Model extraction and optimization complete.
echo ===================================================
echo.
echo The optimized Qwen2.5:7b model has been placed at:
echo %OUTPUT_DIR%\qwen2.5-7b-gguf-q4_0.bin
echo.
echo You can now run the Neonote app with the optimized model.
echo.
goto :end

:error
echo.
echo ===================================================
echo ERROR: Model extraction and optimization failed.
echo ===================================================
echo.
echo Please check the error messages above and try again.
echo.

:end
echo Press any key to exit...
pause >nul
