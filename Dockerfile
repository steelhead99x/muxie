FROM ghcr.io/speaches-ai/speaches:latest-cuda

# Ensure we have permissions to create/cache models
USER root

# Use a safe, writable path for model caches
ENV TTS_HOME=/opt/voices \
    HF_HOME=/opt/voices \
    PATH="/root/.local/bin:${PATH}"

# Prepare model directory, install uv, then pre-download models
RUN set -eux; \
    mkdir -p /opt/voices && chmod -R 777 /opt/voices; \
    curl -LsSf https://astral.sh/uv/install.sh | sh; \
    uvx --version; \



# The base image already starts the service; no need to override CMD.
# If you want an explicit start command:
# CMD ["speaches", "serve", "--host", "0.0.0.0", "--port", "8000"]