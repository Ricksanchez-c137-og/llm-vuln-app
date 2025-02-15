#!/bin/sh
set -e

echo "Pulling Mistral model..."
ollama pull mistral

echo "Starting Ollama server..."
exec ollama serve
