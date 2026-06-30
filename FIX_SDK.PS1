# =============================================================================
# MediGuide AI - Fix objective_c hook + Flutter SDK spaces
#
# The objective_c package hook fails because Flutter's dart.exe is at a
# path with spaces. We fix this by:
# 1. Mapping Flutter SDK to Y: drive (no spaces)
# 2. Updating PATH so flutter/dart use Y: path
# 3. Clearing the hooks_runner cache so it rebuilds with Y: path
#
# HOW TO RUN (in a NEW PowerShell window):
#   powershell -ExecutionPolicy Bypass -File "D:\Desktop\6th Sem\SWE\final_flutter_integration\FIX_SDK.ps1"
# =============================================================================

$PROJECT = "D:\Desktop\6th Sem\SWE\final_flutter_integration"
$SDK     = "D:\Desktop\6th Sem\SWE\flutter_project_dart\flutter"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Fix Flutter SDK spaces + objective_c     " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Step 1: Map Flutter SDK to Y: (no spaces)
Write-Host ""
Write-Host "[1] Mapping Flutter SDK to Y:..." -ForegroundColor Yellow
subst Y: /d 2>$null; Start-Sleep -Milliseconds 200
subst Y: $SDK
if (Test-Path "Y:\bin\flutter.bat") {
    Write-Host "    OK: Y: -> Flutter SDK" -ForegroundColor Green
} else {
    Write-Host "    FAIL: flutter.bat not found at Y:\bin\" -ForegroundColor Red
    Write-Host "    Check: is Flutter SDK really at $SDK ?" -ForegroundColor Red
    exit 1
}

# Step 2: Map project to X: (no spaces)
Write-Host ""
Write-Host "[2] Mapping project to X:..." -ForegroundColor Yellow
subst X: /d 2>$null; Start-Sleep -Milliseconds 200
subst X: $PROJECT
Write-Host "    OK: X: -> project" -ForegroundColor Green

# Step 3: Update PATH and Environment to use Y:\bin (replaces the spaces path)
Write-Host ""
Write-Host "[3] Updating Environment to use Y:\..." -ForegroundColor Yellow

# Remove old flutter path with spaces from PATH
$env:PATH = ($env:PATH -split ';' | Where-Object { $_ -notmatch '6th Sem' -and $_ -notmatch 'flutter_project_dart' -and $_ -notmatch 'ASMI K' }) -join ';'
# Add Y:\bin at front
$env:PATH = "Y:\bin;" + $env:PATH
# Set Environment Variables to Y:
$env:FLUTTER_ROOT = "Y:"
$env:DART_SDK = "Y:\bin\cache\dart-sdk"

Write-Host "    OK: Environment updated (PATH + FLUTTER_ROOT + DART_SDK)" -ForegroundColor Green

# Step 4: Delete the cached hooks_runner so it rebuilds with Y: paths
Write-Host ""
Write-Host "[4] Clearing hooks_runner cache..." -ForegroundColor Yellow
$hooksDir = "$PROJECT\.dart_tool\hooks_runner"
if (Test-Path $hooksDir) {
    Remove-Item $hooksDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "    OK: hooks_runner cache cleared" -ForegroundColor Green
} else {
    Write-Host "    Already clean" -ForegroundColor DarkGray
}

# Step 5: Also clear build cache
Write-Host ""
Write-Host "[5] Running flutter clean via Y: path..." -ForegroundColor Yellow
Set-Location X:\
& "Y:\bin\flutter.bat" clean
Write-Host "    Done" -ForegroundColor Green

# Step 6: flutter pub get via Y: path
Write-Host ""
Write-Host "[6] Running flutter pub get..." -ForegroundColor Yellow
& "Y:\bin\flutter.bat" pub get
Write-Host "    Done" -ForegroundColor Green

# Done
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "   Now run (in THIS same window):          " -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  & 'Y:\bin\flutter.bat' run -d chrome" -ForegroundColor White
Write-Host ""
Write-Host "  OR if that works, just: flutter run -d chrome" -ForegroundColor White
Write-Host "  (since Y:\bin is now in PATH)" -ForegroundColor DarkGray
Write-Host ""