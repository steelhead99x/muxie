FROM ghcr.io/speaches-ai/speaches:latest-cuda

# Ensure we have permissions to create/cache models
USER root

# Use a safe, writable path for model caches
ENV TTS_HOME=/opt/voices \
    HF_HOME=/opt/voices \
    PATH="/root/.local/bin:${PATH}"

# Install required system utilities and prepare model directory
RUN set -eux; \
    apt-get update && apt-get install -y \
        curl \
        coreutils \
        python3 \
        python3-pip \
        && rm -rf /var/lib/apt/lists/*; \
    mkdir -p /opt/voices && chmod -R 777 /opt/voices; \
    curl -LsSf https://astral.sh/uv/install.sh | sh; \
    export PATH="/root/.local/bin:${PATH}"; \
    uvx --version

# Simple entrypoint - just run speaches
ENTRYPOINT ["speaches", "serve", "--host", "0.0.0.0", "--port", "8000"]