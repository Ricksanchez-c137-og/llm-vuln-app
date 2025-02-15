# Use Ubuntu as the base image
FROM ubuntu:22.04

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl git python3 python3-pip python3-venv ca-certificates && \
    apt-get clean

# Install Node.js 18+ from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Ensure Ollama is in the system PATH
ENV PATH="/root/.ollama/bin:$PATH"

# Clone the repo to a temporary location
RUN git clone https://github.com/Ricksanchez-c137-og/llm-vuln-app.git /tmp/repo

# Copy the repo files to /app
RUN cp -r /tmp/repo/* /app/ && rm -rf /tmp/repo

# Copy entrypoint.sh after cloning to avoid conflicts
COPY entrypoint.sh /app
RUN chmod +x /app/entrypoint.sh

# Set the working directory to the application root
WORKDIR /app

# Install Python dependencies
RUN pip3 install fastapi "uvicorn[standard]" requests

# Install Next.js dependencies and build the frontend
RUN npm install --force && npm run build

# Expose API & Frontend ports
EXPOSE 80
EXPOSE 8000

# Start Ollama, FastAPI, and Next.js
CMD ollama serve & uvicorn app:app --host 0.0.0.0 --port 8000 & npm start
