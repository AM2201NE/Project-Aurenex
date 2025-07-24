@echo off
REM Robustly copy the latest built llama_wrapper.dll to app asset and runner directories
setlocal
set DLL_SRC1="%~dp0..\llama_cpp_wrapper\build\bin\Release\llama_wrapper.dll"
set DLL_SRC2="%~dp0..\llama_cpp_wrapper\build\bin\Release\Release\llama_wrapper.dll"
set ASSET_DST="%~dp0..\assets\ai_model\llama_wrapper.dll"
set RUNNER_DST1="%~dp0..\build\windows\x64\runner\Debug\llama_wrapper.dll"
set RUNNER_DST2="%~dp0..\build\windows\x64\runner\Release\llama_wrapper.dll"

REM Ensure destination directories exist
for %%D in ("%~dp0..\assets\ai_model" "%~dp0..\build\windows\x64\runner\Debug" "%~dp0..\build\windows\x64\runner\Release") do (
    if not exist %%D mkdir %%D
)

if exist %DLL_SRC2% (
    set DLL_SRC=%DLL_SRC2%
) else if exist %DLL_SRC1% (
    set DLL_SRC=%DLL_SRC1%
) else (
    echo ERROR: llama_wrapper.dll not found in either expected location.
    exit /b 1
)

copy /Y %DLL_SRC% %ASSET_DST%
copy /Y %DLL_SRC% %RUNNER_DST1%
copy /Y %DLL_SRC% %RUNNER_DST2%
echo DLL copied to all targets.
endlocal
