# Start Development Script (Single Window)
# Starts Docker Compose and runs local Python/React apps in watch mode using background jobs

Write-Host "Starting development environment..." -ForegroundColor Green

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "Warning: .env file not found. Creating default .env file..." -ForegroundColor Yellow
    @"
APP_ENV=development
VITE_API_URL=http://localhost:8007
"@ | Out-File -FilePath ".env" -Encoding utf8
}

# Start Docker Compose (both backend and frontend services)
Write-Host "`nStarting Docker Compose (backend and frontend)..." -ForegroundColor Cyan
docker compose -f docker-compose.dev.yml up -d --build

# Wait for Docker services to initialize
Write-Host "Waiting for Docker services to start..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# Start Backend (Python FastAPI) in watch mode
Write-Host "Starting FastAPI backend locally on port 8007 (watch mode)..." -ForegroundColor Cyan
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD\backend
    $env:APP_ENV = "development"
    python -m uvicorn main:app --host 0.0.0.0 --port 8007 --reload
}

# Wait a moment for backend to start
Start-Sleep -Seconds 2

# Start Frontend (React + Vite) in watch mode
Write-Host "Starting React frontend locally on port 8006 (watch mode)..." -ForegroundColor Cyan
$frontendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD\frontend
    npm run dev
}

Write-Host "`nDevelopment environment started!" -ForegroundColor Green
Write-Host "Docker Backend: http://localhost:8007 (port 8007:8007)" -ForegroundColor Yellow
Write-Host "Docker Frontend: http://localhost:8006 (port 8006:8006)" -ForegroundColor Yellow
Write-Host "Local Backend (watch mode): Starting on port 8007..." -ForegroundColor Cyan
Write-Host "Local Frontend (watch mode): Starting on port 8006..." -ForegroundColor Cyan
Write-Host "`nNote: Port conflicts may occur. Press Ctrl+C to stop local servers." -ForegroundColor Gray
Write-Host "Run 'docker compose -f docker-compose.dev.yml down' to stop Docker services" -ForegroundColor Gray

# Function to cleanup jobs on exit
function Cleanup {
    Write-Host "`nStopping local servers..." -ForegroundColor Red
    Stop-Job -Job $backendJob, $frontendJob -ErrorAction SilentlyContinue
    Remove-Job -Job $backendJob, $frontendJob -ErrorAction SilentlyContinue
}

# Register cleanup on script exit
Register-EngineEvent PowerShell.Exiting -Action { Cleanup } | Out-Null

try {
    # Monitor jobs and display output
    while ($true) {
        # Check if jobs are still running
        if ($backendJob.State -eq "Failed" -or $frontendJob.State -eq "Failed") {
            Write-Host "`nOne of the servers failed. Check output above." -ForegroundColor Red
            break
        }
        
        # Display any output from jobs
        Receive-Job -Job $backendJob, $frontendJob -ErrorAction SilentlyContinue
        
        Start-Sleep -Seconds 1
    }
}
finally {
    Cleanup
}
