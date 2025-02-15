#!/bin/sh
set -e

# Check if Ollama is already running
if pgrep -f "ollama serve" > /dev/null; then
  echo "✅ Ollama is already running, skipping startup..."
else
  echo "🚀 Starting Ollama in the background..."
  ollama serve &
fi

# Wait for Ollama to be fully ready
until ollama list | grep -q "mistral"; do
  echo "⏳ Waiting for Ollama to be fully ready..."
  sleep 2
done

# Pull Mistral if it's not installed
if ! ollama list | grep -q "mistral"; then
  echo "🔄 Pulling Mistral model..."
  ollama pull mistral
fi

echo "✅ Ollama is ready!"
exec tail -f /dev/null  # Keep container running
