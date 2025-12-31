Write-Host "Starting React + FastAPI (DEV mode)..."

# Ensure .env exists
if (-Not (Test-Path ".env")) {
    Write-Error ".env file not found. Aborting."
    exit 1
}

# Stop any existing containers
docker compose -f docker-compose.dev.yml down

# Build and run
docker compose -f docker-compose.dev.yml up --build
