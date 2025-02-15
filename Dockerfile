FROM ubuntu:22.04

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl git python3 python3-pip python3-venv ca-certificates && \
    apt-get clean

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

RUN curl -fsSL https://ollama.com/install.sh | sh

ENV PATH="/root/.ollama/bin:$PATH"

RUN git clone https://github.com/Ricksanchez-c137-og/llm-vuln-app.git /app 

WORKDIR /app

RUN pip3 install fastapi "uvicorn[standard]" requests

RUN npm install --force && npm run build

EXPOSE 80
EXPOSE 8000

CMD ollama serve & uvicorn app:app --host 0.0.0.0 --port 8000 & npm start
