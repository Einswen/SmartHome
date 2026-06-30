# SmartHomeBackend

A minimal Docker-ready backend for the SmartHome project.

## Local Run

```bash
pip install -r requirements.txt
uvicorn src.main:app --host 0.0.0.0 --port 8080
```

Health check:

```text
GET /health
```

## Docker

```bash
docker compose up --build
```

## Portainer

Create a stack with repository mode:

```text
Repository URL: https://github.com/Einswen/SmartHomeBackend.git
Repository reference: refs/heads/main
Compose path: docker-compose.yml
```

Configuration values for Huawei Cloud, DeepSeek, and device credentials should be added later as environment variables.
