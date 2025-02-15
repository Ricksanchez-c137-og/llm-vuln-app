FROM ollama/ollama:latest

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl git python3 python3-pip python3-venv ca-certificates nodejs npm && \
    apt-get clean

RUN git clone https://github.com/Ricksanchez-c137-og/llm-vuln-app.git /tmp/repo

RUN cp -r /tmp/repo/* /app/ && rm -rf /tmp/repo

COPY entrypoint.sh /app
RUN chmod +x /app/entrypoint.sh

WORKDIR /app

RUN pip3 install fastapi "uvicorn[standard]" requests

RUN npm install --force && npm run build

EXPOSE 80
EXPOSE 8000
EXPOSE 11434 

RUN ollama pull mistral && ollama pull llama2 && ollama pull gemma

CMD ollama serve & uvicorn app:app --host 0.0.0.0 --port 8000 & npm start
