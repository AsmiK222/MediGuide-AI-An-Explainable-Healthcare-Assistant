# MediGuide AI - Start All Backends
# This script launches the three backend services in separate terminal windows.
# Uses 'python -m uvicorn' to avoid common Windows PATH issues.

$ROOT = "D:\Desktop\6th Sem\SWE\final_flutter_integration"

# Try to use X: drive if it exists (mapped by RUN_WEB.bat)
if (Test-Path "X:\") {
    $ROOT = "X:"
}

Write-Host "Starting MediGuide AI Backends..." -ForegroundColor Cyan

# Service 1: Geshna (Symptom Checker) - Port 8000
Write-Host "Launching Symptom Checker (Port 8000)..." -ForegroundColor Yellow
$cmd1 = "Set-Location `"$ROOT\backend\symptom_checker`"; python -m uvicorn main:app --reload --port 8000"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd1

# Service 2: Vibhu (Drug Intelligence) - Port 8001
Write-Host "Launching Drug Intelligence (Port 8001)..." -ForegroundColor Yellow
$cmd2 = "Set-Location `"$ROOT\backend\pill_identifier`"; python -m uvicorn main:app --reload --port 8001"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd2

# Service 3: Malavika (Doctor Portal) - Port 8002
Write-Host "Launching Doctor Portal (Port 8002)..." -ForegroundColor Yellow
$cmd3 = "Set-Location `"$ROOT\backend\doctor_portal`"; python -m uvicorn main:app --reload --port 8002"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $cmd3

Write-Host "All backends launching in separate windows." -ForegroundColor Green
Write-Host "Keep those windows open while using the app!" -ForegroundColor Cyan
