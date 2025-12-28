from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/api/hello")
async def hello():
    env = os.getenv("APP_ENV", "development")
    return {
        "message": "Hello from FastAPI!",
        "env": env
    }

