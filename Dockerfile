FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive TZ=Asia/Dubai

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl git python3 python3-pip python3-venv ca-certificates tzdata && \
    apt-get clean && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v  # Verify installation
RUN curl -fsSL https://ollama.com/install.sh | sh

ENV PATH="/root/.ollama/bin:$PATH"

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

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/bin/sh", "/start.sh"]
