FROM python:3.10-slim

# PyPI 国内镜像（任选其一，或都配）
ENV UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
ENV UV_EXTRA_INDEX_URL=https://mirrors.aliyun.com/pypi/simple

# 提高 uv 的网络容错
ENV UV_HTTP_TIMEOUT=120
ENV UV_HTTP_RETRIES=5
ENV UV_HTTP_CONCURRENCY=4

# Install dependencies and check espeak location
# Rust is required to build sudachipy and pyopenjtalk-plus
RUN apt-get update -y &&  \
    apt-get install -y espeak-ng espeak-ng-data git libsndfile1 curl ffmpeg g++ cmake && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/share/espeak-ng-data && \
    ln -s /usr/lib/*/espeak-ng-data/* /usr/share/espeak-ng-data/ && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/ && \
    mv /root/.local/bin/uvx /usr/local/bin/ && \
    useradd -m -u 1000 appuser && \
    mkdir -p /app/api/src/models/v1_0 && \
    chown -R appuser:appuser /app

USER appuser
WORKDIR /app

# Install Rust for the non-root user so builds (e.g., sudachipy) succeed
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Ensure Cargo and the Python venv are on PATH; extend HTTP timeouts for uv
ENV PATH="/home/appuser/.cargo/bin:/app/.venv/bin:$PATH" \
    UV_HTTP_TIMEOUT=120 \
    UV_HTTP_RETRIES=3

# Copy dependency files
COPY --chown=appuser:appuser pyproject.toml ./pyproject.toml

# Install dependencies with CPU extras
RUN uv venv --python 3.10 && \
    uv sync --extra cpu --no-cache

# Copy project files including models
COPY --chown=appuser:appuser api ./api
COPY --chown=appuser:appuser web ./web
COPY --chown=appuser:appuser docker/scripts/ ./
RUN chmod +x ./entrypoint.sh

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app:/app/api \
    UV_LINK_MODE=copy \
    USE_GPU=false \
    PHONEMIZER_ESPEAK_PATH=/usr/bin \
    PHONEMIZER_ESPEAK_DATA=/usr/share/espeak-ng-data \
    ESPEAK_DATA_PATH=/usr/share/espeak-ng-data \
    DEVICE="cpu"

ENV DOWNLOAD_MODEL=true
# Download model if enabled
RUN if [ "$DOWNLOAD_MODEL" = "true" ]; then \
    python download_model.py --output api/src/models/v1_0; \
    fi

# Run FastAPI server through entrypoint.sh
CMD ["./entrypoint.sh"]
