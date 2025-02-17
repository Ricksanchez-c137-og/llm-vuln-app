#!/bin/sh
echo "ADMIN ONLY"
echo "Starting Ollama..."
ollama serve &

until curl -s http://127.0.0.1:11434/api/tags > /dev/null; do
  echo "Waiting for Ollama to start..."
  sleep 2
done
echo "Pulling AI models..."
ollama pull mistral
echo "Models loaded successfully!"
echo "Starting FastAPI and Next.js..."
uvicorn app:app --host 0.0.0.0 --port 8000 & npm start