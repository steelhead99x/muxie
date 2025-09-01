#!/bin/bash
set -euo pipefail

# Configuration
VOICES_DIR="${TTS_HOME:-/opt/voices}"
STT_MODEL="Systran/faster-distil-whisper-small.en"
TTS_MODEL="speaches-ai/Kokoro-82M-v1.0-ONNX"
SPEACHES_URL="http://speaches:8000"

echo "=== Speaches Model Download Script ==="
echo "Voices directory: $VOICES_DIR"
echo "Speaches URL: $SPEACHES_URL"

# Function to check if a model exists in the voices directory
check_model_exists() {
    local model_name="$1"
    local model_dir_name=$(echo "$model_name" | tr '/' '_')

    # Check for common model file patterns
    if [ -d "$VOICES_DIR/models--$model_dir_name" ] || \
       [ -d "$VOICES_DIR/$model_dir_name" ] || \
       find "$VOICES_DIR" -name "*$model_dir_name*" -type d 2>/dev/null | grep -q .; then
        return 0  # Model exists
    else
        return 1  # Model doesn't exist
    fi
}

# Function to download model using speaches-cli
download_model() {
    local model="$1"
    local model_type="$2"

    echo "Downloading $model_type model: $model"

    # Try different methods to download the model
    local success=false

    # Method 1: Try using pip-installed speaches-cli
    if command -v speaches-cli >/dev/null 2>&1; then
        echo "  Trying pip-installed speaches-cli..."
        if speaches-cli --base-url "$SPEACHES_URL" model download "$model"; then
            echo "✓ Successfully downloaded $model using speaches-cli"
            success=true
        fi
    fi

    # Method 2: Try using uvx speaches-cli (if pip method failed)
    if [ "$success" = false ] && command -v uvx >/dev/null 2>&1; then
        echo "  Trying uvx speaches-cli..."
        export PATH="/root/.local/bin:$PATH"
        if SPEACHES_BASE_URL="$SPEACHES_URL" uvx speaches-cli model download "$model" 2>/dev/null; then
            echo "✓ Successfully downloaded $model using uvx"
            success=true
        fi
    fi

    # Method 3: Try direct API call
    if [ "$success" = false ]; then
        echo "  Trying direct API call..."
        if curl -X POST "$SPEACHES_URL/v1/models" \
            -H "Content-Type: application/json" \
            -d "{\"id\": \"$model\"}" \
            -f -s >/dev/null 2>&1; then
            echo "✓ Successfully requested download of $model via API"
            success=true
        fi
    fi

    if [ "$success" = false ]; then
        echo "⚠ Failed to download $model using all methods"
        return 1
    fi

    return 0
}

# Main execution
main() {
    echo "Checking if Speaches API is accessible..."
    if ! curl -f -s "$SPEACHES_URL/v1/registry" >/dev/null 2>&1; then
        echo "✗ Speaches API is not accessible at $SPEACHES_URL"
        echo "Make sure the speaches service is running and healthy"
        exit 1
    fi
    echo "✓ Speaches API is accessible"

    # Ensure voices directory exists
    mkdir -p "$VOICES_DIR"

    echo "Checking existing models..."

    # Check and download STT model
    if check_model_exists "$STT_MODEL"; then
        echo "✓ STT model already exists: $STT_MODEL"
    else
        echo "✗ STT model missing, downloading: $STT_MODEL"
        download_model "$STT_MODEL" "STT" || echo "⚠ STT model download failed, but continuing..."
    fi

    # Check and download TTS model
    if check_model_exists "$TTS_MODEL"; then
        echo "✓ TTS model already exists: $TTS_MODEL"
    else
        echo "✗ TTS model missing, downloading: $TTS_MODEL"
        download_model "$TTS_MODEL" "TTS" || echo "⚠ TTS model download failed, but continuing..."
    fi

    echo "✓ Model download process completed"
}

# Run main function
main "$@"