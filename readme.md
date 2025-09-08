# Mux MCP Voice AI Assistant

A simple, local stack to run a voice-enabled AI assistant for Mux MCP using:
- Ollama (LLM runtime)
- Open WebUI (chat UI)
- MCPO (MCP Orchestrator)
- Speaches (Text-to-Speech and Speech-to-Text)

## Prerequisites
- Docker and Docker Compose
- NVIDIA Container Toolkit if using GPU
- Recommended: NVIDIA GPU (e.g., RTX 3090 with 16 GB VRAM). CPU will work but will not work with current configuration (see cpu branch).
- Recommended 40GB of free space on storage drive

## Quick Start
1) Configure environment:
   - Copy the sample file and fill in any needed values (tokens/keys).
     ```bash
     cp sample.env speech.env
     ```
   - Never commit real secrets to version control.

2) Start the stack:
   ```bash
   #sample.env update variables as needed
   cp sample.env speech.env 
   docker compose up --detach
   docker exec -it muxie-speaches-1 uvx speaches-cli model download speaches-ai/Kokoro-82M-v1.0-ONNX  
   docker exec -it muxie-speaches-1 uvx speaches-cli model download Systran/faster-distil-whisper-small.en
   #docker exec -it muxie-speaches-1 uvx speaches-cli model download Systran/faster-distil-whisper-small.en 
   #Install Model using openweb-ui model admin (gpt-oss:20b)
   #Setup Mux MCPO at http://mcpo:8001/mux and verify connection
   #Goto Connections -> Disable openai api and enable third party option
   ```
   - First startup may take time as models/images are pulled and initialized.

3) Open the services:
   - Open WebUI: http://localhost:3000
   - MCPO API: http://localhost:8001
   - Speaches API: http://localhost:8000
   - Ollama API: http://localhost:11434

## Models (Ollama)
- Pull a default LLM via Open WebUI:
  - Open http://localhost:3000
  - Go to Settings -> Models -> Pull
  - Enter llama3.1 (or any supported model) and click Pull
  - After download, set it as the default model in Settings or pick it in a new chat
- Pull a default LLM via API (example: Llama 3.1 8B):
  ```bash
  curl http://localhost:11434/api/pull -d '{"name":"llama3.1"}'
  ```
- List models:
  ```bash
  curl http://localhost:11434/api/tags
  ```
- Change the default model in your UI or environment as needed.

## Models (Speaches)
- Model discovery guide:
  https://speaches.ai/usage/model-discovery/

- Install Speech-to-Text (STT) model (Whisper-small EN):
  ```bash
  uvx speaches-cli model download Systran/faster-distil-whisper-small.en
  ```

- Install Text-to-Speech (TTS) model (Kokoro):
  ```bash
  uvx speaches-cli model download speaches-ai/Kokoro-82M-v1.0-ONNX
  ```

- List available TTS voices (filtering for Kokoro):
  ```bash
  uvx speaches-cli model ls --task text-to-speech | jq '.data | map(select(.id == "speaches-ai/Kokoro-82M-v1.0-ONNX"))'
  ```

## Configuration
- Compose file: compose.yaml (used by default with docker compose).
- MCPO config: edit mcpo_config.json to adjust MCP tools/providers. A copy is also provided under files/mcp/mcpo_config/ for reference or mounting.

## Audio Settings
- You can tweak audio and model settings via environment variables in `speech.env` (e.g., default voice, STT provider, etc.).
- Example variables include:
  - TTS_API_BASE_URL, TTS_API_KEY, TTS_VOICE
  - STT_PROVIDER, AUDIO_STT_MODEL

## GPU Notes
- A strong NVIDIA GPU is recommended (e.g., RTX 3090 16GB). The stack has been tested on systems with 8GB VRAM GPUs as well but expect reduced performance.
- If running on CPU-only, expect slower inference. Ensure your chosen models fit available memory.

## Managing the Stack
- Stop:
  ```bash
  docker compose down
  ```
- View logs (example for Speaches):
  ```bash
  docker compose logs -f speaches
  ```

## Troubleshooting
- If a service is not reachable, wait a moment and check logs:
  ```bash
  docker compose ps
  docker compose logs -f
  ```
- Ensure environment variables in `speech.env` are set correctly.
- This project is built for nvidia GPU (see cpu branch for contributions, and consider using a minimum 16GB GTX NVIDIA 5xxx or multiple GPU config)

## Credits
This project builds on and integrates the following open-source projects:
- Speaches (container image): https://github.com/speaches-ai/speaches/pkgs/container/speaches
- Open WebUI: https://github.com/open-webui/open-webui
- MCPO (Model Context Protocol Orchestrator): https://github.com/open-webui/mcpo
- Ollama: https://github.com/ollama/ollama
- Mux MCP: https://www.npmjs.com/package/@mux/mcp
