from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import requests
import os
import json
import asyncio

app = FastAPI()

OLLAMA_API = os.getenv("OLLAMA_API_BASE", "http://localhost:11434")

PRELOAD_MODELS = ["mistral", "llama2", "gemma"]

async def preload_models():
    for model in PRELOAD_MODELS:
        print(f"🔄 Preloading model: {model}...")

        try:
            response = requests.post(f"{OLLAMA_API}/api/pull", json={"name": model}, timeout=300)
            if response.status_code == 200:
                print(f"✅ Model {model} preloaded successfully!")
            else:
                print(f"Failed to preload {model}: {response.status_code} - {response.text}")
        except requests.exceptions.RequestException as e:
            print(f" Error connecting to Ollama while preloading model {model}: {e}")

@app.on_event("startup")
async def startup_event():
    await asyncio.sleep(5)  
    await preload_models() 

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_text()

            try:
                request_data = json.loads(data)
                prompt = request_data.get("prompt", "Hello!")
                model = request_data.get("model", "mistral")

                print(f"Received request: Model={model}, Prompt={prompt}")

                response = requests.post(
                    f"{OLLAMA_API}/api/generate",
                    json={"model": model, "prompt": prompt},
                    stream=True,
                    timeout=300 
                )

                if response.status_code != 200:
                    error_msg = f"Ollama API Error: {response.status_code} - {response.text}"
                    print(error_msg)
                    await websocket.send_text(error_msg)
                    continue

                for line in response.iter_lines():
                    if line:
                        chunk = json.loads(line.decode("utf-8"))
                        if "response" in chunk:
                            await websocket.send_text(chunk["response"])
                        if chunk.get("done", False):
                            break

            except json.JSONDecodeError:
                print("Received invalid JSON from client")
                await websocket.send_text("Invalid JSON format")
            except requests.exceptions.RequestException as e:
                print(f"Error calling Ollama API: {e}")
                await websocket.send_text(f"Ollama API error: {e}")

    except WebSocketDisconnect:
        print("WebSocket client disconnected")
    except Exception as e:
        print(f"WebSocket error: {e}")
        await websocket.close()

@app.get("/")
async def root():
    """Root endpoint to check if the API is running."""
    return {"message": "Ollama WebSocket API is running!"}
