# Stage 1: Build & Cache Ollama Model Layer
FROM python:3.11-slim AS model-cache

RUN apt-get update && apt-get install -y curl zstd && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://ollama.com/install.sh | sh

RUN ollama serve & \
    until curl -s http://localhost:11434/api/tags > /dev/null; do sleep 1; done && \
    ollama pull gemma:2b && \
    pkill ollama

# Stage 2: Runtime Environment
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl zstd && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir fastapi uvicorn httpx pydantic

COPY --from=model-cache /usr/local/bin/ollama /usr/local/bin/ollama
COPY --from=model-cache /root/.ollama /root/.ollama

COPY . /app/public

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:11434/api/tags || exit 1

CMD ollama serve & \
    echo "Waiting for Ollama daemon to initialize (5-minute retry limit)..." && \
    counter=0; \
    until curl -s http://localhost:11434/api/tags > /dev/null; do \
        sleep 1; \
        counter=$((counter+1)); \
        if [ $counter -ge 300 ]; then \
            echo "Error: Ollama daemon failed to start within 5 minutes."; \
            exit 1; \
        fi; \
    done && \
    echo "Ollama ready. Launching FastAPI server..." && \
    uvicorn public.server:app --host 0.0.0.0 --port 8000