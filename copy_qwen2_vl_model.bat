@echo off
rem Script to copy and rename the Qwen2-VL-2B-Instruct model for Neonote

echo ===================================================
echo Neonote Model Setup: Qwen2-VL-2B-Instruct
echo ===================================================
echo.

rem Set variables
set SOURCE_MODEL_NAME=Qwen2-VL-2B-Instruct-Q4_K_M.gguf
set TARGET_MODEL_NAME=qwen2-vl-2b-instruct-q4_k_m.bin
set SOURCE_DIR=%USERPROFILE%\Desktop
set TARGET_DIR=%USERPROFILE%\Desktop\notion_offline\assets\ai_model

set SOURCE_PATH=%SOURCE_DIR%\%SOURCE_MODEL_NAME%
set TARGET_PATH=%TARGET_DIR%\%TARGET_MODEL_NAME%

echo Source Model Path: %SOURCE_PATH%
echo Target Model Path: %TARGET_PATH%
echo.

rem Check if source model file exists on Desktop
if not exist "%SOURCE_PATH%" (
    echo ERROR: Model file not found on your Desktop!
    echo.
    echo Please ensure the file "%SOURCE_MODEL_NAME%" is located at "%SOURCE_DIR%"
    echo.
    echo Checking for alternative filenames...
    
    rem Try alternative filenames
    for %%f in ("%SOURCE_DIR%\Qwen2-VL-2B*.gguf") do (
        echo Found potential model file: %%~nxf
        set SOURCE_MODEL_NAME=%%~nxf
        set SOURCE_PATH=%%f
        goto :found_alternative
    )
    
    echo No alternative model files found.
    goto :error
)

:found_alternative
echo Using model file: %SOURCE_MODEL_NAME%
echo.

rem Check if target directory exists, create if not
if not exist "%TARGET_DIR%" (
    echo Creating target directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%" 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Failed to create target directory.
        goto :error
    )
)

rem Copy the model file
echo Copying model file from Desktop to Neonote assets...
copy "%SOURCE_PATH%" "%TARGET_PATH%" > nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to copy the model file.
    echo Please check permissions and disk space.
    goto :error
)

echo.
echo ===================================================
echo SUCCESS! Model setup complete.
echo ===================================================
echo.
echo The model "%TARGET_MODEL_NAME%" has been placed at:
echo %TARGET_PATH%
echo.
echo You can now run the Neonote app with the new multimodal AI assistant.
echo.
goto :end

:error
echo.
echo ===================================================
echo ERROR: Model setup failed.
echo ===================================================
echo.
echo Please check the error messages above and try again.

:end
echo Press any key to exit...
pause >nul
