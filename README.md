# demo

## Local Development (Without Docker)

### Option 1: Use PowerShell Script (Recommended)

Run the simple script to start both services in separate windows:


```powershell
.\start-dev.ps1
```

### Option 2: Manual Commands

**Terminal 1 - Backend:**
```powershell
cd backend
$env:APP_ENV="development"
python -m uvicorn main:app --host 0.0.0.0 --port 8007 --reload
```

**Terminal 2 - Frontend:**
```powershell
cd frontend
npm install  # First time only
npm run dev
```

### Access
- Frontend: http://localhost:8006
- Backend API: http://localhost:8007/api/hello

## Docker Development

```powershell
docker compose -f docker-compose.dev.yml up --build
```
