# Qwen2.5:7b Model Conversion Guide

This package contains scripts to convert and optimize the Qwen2.5:7b model from Ollama format to GGUF format with q4_0 quantization for use with the Neonote application.

## Contents

- `build_all.sh`: Master script that orchestrates the entire conversion process
- `extract_ollama_model.py`: Extracts the model from Ollama format
- `convert_to_gguf.py`: Converts the extracted model to GGUF format
- `quantize_model.py`: Quantizes the GGUF model to q4_0 precision
- `optimize_model.py`: Optimizes the quantized model with FlashAttention

## Usage

1. Ensure you have Python 3.8+ and required dependencies installed
2. Run the master script:

```bash
./scripts/build_all.sh --model-path /path/to/ollama/model/blobs --output-dir ./output --quantize q4_0
```

## Windows Usage

On Windows, you can run the Python scripts individually:

```cmd
python scripts\extract_ollama_model.py --input-dir C:\path\to\ollama\model\blobs --output-dir output\extracted
python scripts\convert_to_gguf.py --input-dir output\extracted --output-dir output\gguf
python scripts\quantize_model.py --input-file output\gguf\qwen2.5-7b.gguf --output-dir output --quantize q4_0
python scripts\optimize_model.py --input-file output\qwen2.5-7b-q4_0.gguf --output-dir output
```

## Output

The final optimized model will be saved as `qwen2.5-7b-gguf-q4_0.bin` in the output directory.
Copy this file to your Neonote project's `assets/ai_model/` directory to use it with the app.
