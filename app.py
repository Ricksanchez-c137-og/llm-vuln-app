from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import requests
import os
import json
import asyncio

app = FastAPI()

OLLAMA_API = os.getenv("OLLAMA_API_BASE", "http://ollama:11434")

# Preload multiple AI models
PRELOAD_MODELS = ["mistral", "llama2", "gemma"]

async def preload_models():
    for model in PRELOAD_MODELS:
        print(f"Preloading model: {model}...")
        response = requests.post(f"{OLLAMA_API}/api/pull", json={"name": model})
        if response.status_code == 200:
            print(f"Model {model} preloaded successfully!")
        else:
            print(f"Failed to preload {model}: {response.text}")

@app.on_event("startup")
async def startup_event():
    await asyncio.create_task(preload_models())

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()
            request_data = json.loads(data)
            prompt = request_data.get("prompt", "Hello!")
            model = request_data.get("model", "mistral")  # Default to Mistral

            print(f"User request: Model={model}, Prompt={prompt}")

            response = requests.post(
                f"{OLLAMA_API}/api/generate",
                json={"model": model, "prompt": prompt},
                stream=True
            )

            for line in response.iter_lines():
                if line:
                    chunk = json.loads(line.decode("utf-8"))
                    if "response" in chunk:
                        await websocket.send_text(chunk["response"])
                    if chunk.get("done", False):
                        break
    except WebSocketDisconnect:
        print("WebSocket client disconnected")
    except Exception as e:
        print(f"Error: {e}")
        await websocket.close()

@app.get("/")
async def root():
    return {"message": "✅ Ollama WebSocket API is running!"}
