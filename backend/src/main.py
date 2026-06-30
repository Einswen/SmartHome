from fastapi import FastAPI

app = FastAPI(title="SmartHome Backend")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/")
def root() -> dict[str, str]:
    return {"message": "SmartHome Backend is running"}
