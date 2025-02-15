FROM ubuntu:22.04

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl git python3 python3-pip python3-venv \
    nodejs npm \
    && apt-get clean

RUN curl -fsSL https://ollama.com/install.sh | sh



ENV PATH="/root/.ollama/bin:$PATH"

COPY app.py /app/app.py

RUN pip3 install fastapi uvicorn requests

RUN npm install && npm run build

EXPOSE 80
EXPOSE 8000

CMD ollama serve & uvicorn app:app --host 0.0.0.0 --port 8000 & npm start