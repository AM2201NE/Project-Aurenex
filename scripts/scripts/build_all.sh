#!/bin/bash
set -e

# Master build script for Qwen2.5:7b model conversion and optimization
# This script handles the entire pipeline from Ollama model to optimized GGUF

# Default parameters
MODEL_PATH=""
OUTPUT_DIR="./output"
QUANTIZE="q4_0"
THREADS=$(nproc)
TARGET_PLATFORM="all"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --model-path)
      MODEL_PATH="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --quantize)
      QUANTIZE="$2"
      shift 2
      ;;
    --threads)
      THREADS="$2"
      shift 2
      ;;
    --target)
      TARGET_PLATFORM="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [ -z "$MODEL_PATH" ]; then
  echo "Error: --model-path is required"
  echo "Usage: $0 --model-path /path/to/ollama/model/blobs --output-dir ./output --quantize q4_0 --threads 8 --target all"
  exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Step 1: Extract model from Ollama format
echo "Step 1: Extracting model from Ollama format..."
python ./scripts/extract_ollama_model.py --input-dir "$MODEL_PATH" --output-dir "$OUTPUT_DIR/extracted"

# Step 2: Convert to GGUF format
echo "Step 2: Converting to GGUF format..."
python ./scripts/convert_to_gguf.py --input-dir "$OUTPUT_DIR/extracted" --output-dir "$OUTPUT_DIR/gguf"

# Step 3: Quantize the model
echo "Step 3: Quantizing the model to $QUANTIZE..."
python ./scripts/quantize_model.py --input-file "$OUTPUT_DIR/gguf/qwen2.5-7b.gguf" --output-dir "$OUTPUT_DIR" --quantize "$QUANTIZE" --threads "$THREADS"

# Step 4: Optimize with FlashAttention
echo "Step 4: Optimizing with FlashAttention..."
python ./scripts/optimize_model.py --input-file "$OUTPUT_DIR/qwen2.5-7b-$QUANTIZE.gguf" --output-dir "$OUTPUT_DIR" --threads "$THREADS"

# Step 5: Rename final output for Neonote
echo "Step 5: Preparing final output for Neonote..."
cp "$OUTPUT_DIR/qwen2.5-7b-$QUANTIZE-optimized.gguf" "$OUTPUT_DIR/qwen2.5-7b-gguf-q4_0.bin"

echo "Conversion complete! The optimized model is available at: $OUTPUT_DIR/qwen2.5-7b-gguf-q4_0.bin"
echo "Copy this file to your Neonote project's assets/ai_model/ directory to use it with the app."
