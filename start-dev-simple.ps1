# Start Development Script
# Starts Docker Compose and runs local Python/React apps in watch mode

Write-Host "Starting development environment..." -ForegroundColor Green

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "Warning: .env file not found. Creating default .env file..." -ForegroundColor Yellow
    @"
APP_ENV=development
VITE_API_URL=http://localhost:8007
"@ | Out-File -FilePath ".env" -Encoding utf8
}

# Get current directory
$rootDir = Get-Location

# Start Docker Compose (both backend and frontend services)
Write-Host "`nStarting Docker Compose (backend and frontend)..." -ForegroundColor Cyan
docker compose -f docker-compose.dev.yml up -d --build

# Wait for Docker services to initialize
Write-Host "Waiting for Docker services to start..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# Start Backend (Python FastAPI) in watch mode in new window
Write-Host "Starting FastAPI backend locally on port 8007 (watch mode)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$rootDir\backend'; `$env:APP_ENV='development'; python -m uvicorn main:app --host 0.0.0.0 --port 8007 --reload"

# Wait a moment for backend to start
Start-Sleep -Seconds 2

# Start Frontend (React + Vite) in watch mode in new window
Write-Host "Starting React frontend locally on port 8006 (watch mode)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$rootDir\frontend'; npm run dev"

Write-Host "`nDevelopment environment started!" -ForegroundColor Green
Write-Host "Docker Backend: http://localhost:8007 (port 8007:8007)" -ForegroundColor Yellow
Write-Host "Docker Frontend: http://localhost:8006 (port 8006:8006)" -ForegroundColor Yellow
Write-Host "Local Backend (watch mode): Starting on port 8007..." -ForegroundColor Cyan
Write-Host "Local Frontend (watch mode): Starting on port 8006..." -ForegroundColor Cyan
Write-Host "`nNote: Port conflicts may occur. Close PowerShell windows to stop local servers." -ForegroundColor Gray
Write-Host "Run 'docker compose -f docker-compose.dev.yml down' to stop Docker services" -ForegroundColor Gray
