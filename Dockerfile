# small, generic Dockerfile — adjust CMD to match your app entrypoint
FROM python:3.11-slim AS base

# If your app is Node/Java use the respective FROM base (see Node/Python/Java examples below)

WORKDIR /app
# copy app files
COPY . /app

# default: if requirements.txt present, install
RUN if [ -f requirements.txt ]; then \
      apt-get update && apt-get install -y build-essential gcc libpq-dev --no-install-recommends && \
      pip install --no-cache-dir -r requirements.txt && \
      apt-get remove -y build-essential gcc && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*; \
    fi

ENV PORT=8000
EXPOSE ${PORT}

# default command — override per stack
CMD ["sh", "-c", "echo 'Adjust Dockerfile CMD to start your application' && sleep 3600"]
