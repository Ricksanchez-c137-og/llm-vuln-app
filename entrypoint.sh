#!/bin/sh
set -e
echo "Starting Ollama server..."
exec ollama serve

echo "Pulling Mistral model..."
ollama pull mistral

