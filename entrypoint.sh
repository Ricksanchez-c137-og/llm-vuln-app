#!/bin/sh
set -e

echo "🚀 Starting Ollama server..."
ollama serve &

# Wait for Ollama API to become available
until curl -s http://127.0.0.1:11434/api/tags > /dev/null; do
  echo "⏳ Waiting for Ollama to start..."
  sleep 2
done

# Pull required models
echo "🚀 Pulling AI models..."
ollama pull mistral
ollama pull llama2
ollama pull gemma

echo "✅ Models pulled successfully. Ollama is ready!"

# Keep Ollama in the foreground
wait
