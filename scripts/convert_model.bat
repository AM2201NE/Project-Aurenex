@echo off
echo Starting Qwen2.5:7b model conversion...

set OLLAMA_BLOBS=C:\Users\nsc\.ollama\models\blobs
set OUTPUT_DIR=%USERPROFILE%\Desktop\neonote_model_output

echo Creating output directory...
mkdir "%OUTPUT_DIR%"

echo Step 1: Extracting model from Ollama format...
python scripts\extract_ollama_model.py --input-dir "%OLLAMA_BLOBS%" --output-dir "%OUTPUT_DIR%\extracted"

echo Step 2: Converting to GGUF format...
python scripts\convert_to_gguf.py --input-dir "%OUTPUT_DIR%\extracted" --output-dir "%OUTPUT_DIR%\gguf"

echo Step 3: Quantizing the model...
python scripts\quantize_model.py --input-file "%OUTPUT_DIR%\gguf\qwen2.5-7b.gguf" --output-dir "%OUTPUT_DIR%" --quantize q4_0

echo Step 4: Optimizing with FlashAttention...
python scripts\optimize_model.py --input-file "%OUTPUT_DIR%\qwen2.5-7b-q4_0.gguf" --output-dir "%OUTPUT_DIR%"

echo Step 5: Preparing final output for Neonote...
copy "%OUTPUT_DIR%\qwen2.5-7b-q4_0-optimized.gguf" "%OUTPUT_DIR%\qwen2.5-7b-gguf-q4_0.bin"

echo Conversion complete! The optimized model is available at: %OUTPUT_DIR%\qwen2.5-7b-gguf-q4_0.bin

echo Copying model to Neonote app...
set NEONOTE_DIR=%USERPROFILE%\Desktop\neonote_fixed
mkdir "%NEONOTE_DIR%\assets\ai_model" 2>nul
copy "%OUTPUT_DIR%\qwen2.5-7b-gguf-q4_0.bin" "%NEONOTE_DIR%\assets\ai_model\"

echo Model successfully copied to Neonote app!
echo You can now run the Neonote app with the optimized model.
pause
