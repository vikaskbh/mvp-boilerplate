Write-Host "Starting React + FastAPI (PROD mode)..."

# Ensure .env exists
if (-Not (Test-Path ".env")) {
    Write-Error ".env file not found. Aborting."
    exit 1
}

# Pull latest images
docker compose -f docker-compose.prod.yml pull

# Stop old containers
docker compose -f docker-compose.prod.yml down

# Run in detached mode
docker compose -f docker-compose.prod.yml up -d

Write-Host "App is running:"
Write-Host "Frontend: http://localhost:8006"
Write-Host "Backend : http://localhost:8007"
