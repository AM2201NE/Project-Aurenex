import os
import json
import argparse
from pathlib import Path

def extract_ollama_model(input_dir, output_dir):
    """
    Extract Qwen2.5:7b model from Ollama format
    
    Args:
        input_dir: Path to Ollama model blobs directory
        output_dir: Path to output directory for extracted model
    """
    print(f"Extracting Qwen2.5:7b model from Ollama format...")
    print(f"Input directory: {input_dir}")
    print(f"Output directory: {output_dir}")
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Find model.json in Ollama directory
    model_json_path = None
    for root, dirs, files in os.walk(input_dir):
        for file in files:
            if file == "model.json" and "qwen2.5:7b" in root.lower():
                model_json_path = os.path.join(root, file)
                break
        if model_json_path:
            break
    
    if not model_json_path:
        # Try to find any model.json as fallback
        for root, dirs, files in os.walk(input_dir):
            for file in files:
                if file == "model.json":
                    model_json_path = os.path.join(root, file)
                    break
            if model_json_path:
                break
    
    if not model_json_path:
        raise FileNotFoundError(f"Could not find model.json in {input_dir}")
    
    print(f"Found model.json at {model_json_path}")
    
    # Load model.json
    with open(model_json_path, 'r') as f:
        model_json = json.load(f)
    
    # Extract model files
    model_files = model_json.get('params', {}).get('files', [])
    if not model_files:
        raise ValueError("No model files found in model.json")
    
    # Copy model files to output directory
    for file_info in model_files:
        file_path = file_info.get('path')
        if not file_path:
            continue
        
        # Resolve file path
        if os.path.isabs(file_path):
            src_path = file_path
        else:
            src_path = os.path.join(os.path.dirname(model_json_path), file_path)
        
        if not os.path.exists(src_path):
            print(f"Warning: File {src_path} not found, skipping")
            continue
        
        # Copy file
        dst_path = os.path.join(output_dir, os.path.basename(file_path))
        print(f"Copying {src_path} to {dst_path}")
        
        with open(src_path, 'rb') as src, open(dst_path, 'wb') as dst:
            dst.write(src.read())
    
    # Create model config file
    config = {
        "model_type": "qwen",
        "model_size": "7b",
        "vocab_size": model_json.get('params', {}).get('vocab_size', 151936),
        "hidden_size": model_json.get('params', {}).get('hidden_size', 4096),
        "num_attention_heads": model_json.get('params', {}).get('num_attention_heads', 32),
        "num_hidden_layers": model_json.get('params', {}).get('num_hidden_layers', 32),
        "intermediate_size": model_json.get('params', {}).get('intermediate_size', 11008),
        "max_position_embeddings": model_json.get('params', {}).get('max_position_embeddings', 4096),
        "extracted_from_ollama": True
    }
    
    with open(os.path.join(output_dir, 'config.json'), 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"Extraction complete. Model files extracted to {output_dir}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract Qwen2.5:7b model from Ollama format")
    parser.add_argument("--input-dir", required=True, help="Path to Ollama model blobs directory")
    parser.add_argument("--output-dir", required=True, help="Path to output directory for extracted model")
    
    args = parser.parse_args()
    extract_ollama_model(args.input_dir, args.output_dir)
