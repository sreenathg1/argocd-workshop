import os

from fastapi import FastAPI 
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from jinja2 import Environment, FileSystemLoader

# Initialize FastAPI app
app = FastAPI()

# Mount static files
app.mount("/assets", StaticFiles(directory="assets"), name="assets")

# Jinja2 environment
templates = Environment(loader=FileSystemLoader("templates"))

# Environment variables
CLUSTER = os.getenv("CLUSTER", "Cluster not set")
IMAGE = os.getenv("IMAGE", "Image not set")

# Routes
@app.get("/", response_class=HTMLResponse)
async def index():
    try:
        # Read API key from file
        # with open("/secrets/api_key.secret", mode="r", encoding="utf-8") as file:
        #     api_key = file.read().strip()

        api_key = "hello"

        # Render template
        template = templates.get_template("index.html")
        rendered = template.render(
            cluster=CLUSTER,
            image=IMAGE,
            cluster_image="/assets/sample-image.png",
            api_key=api_key
        )
        return HTMLResponse(content=rendered)
    except Exception as e:
        return HTMLResponse(content=f"Error: {str(e)}", status_code=500)

@app.get("/health")
async def health():
    return {"status": "alive"}

@app.get("/ready")
async def readiness():
    return {"status": "ready"}
