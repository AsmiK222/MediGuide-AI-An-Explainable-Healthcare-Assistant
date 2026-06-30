@echo off
setlocal

set "PROJECT_DIR=%~dp0"
set "SDK_DIR=D:\Desktop\6th Sem\SWE\flutter_project_dart\flutter"

echo ============================================
echo    MediGuide AI - Easy Build (No Spaces)
echo ============================================

:: 1. Map Drives
echo [1] Mapping drives...
subst Y: /d >nul 2>&1
subst Y: "%SDK_DIR%"
if errorlevel 1 (
    echo FAIL: Could not map SDK to Y:
    pause
    exit /b 1
)

subst X: /d >nul 2>&1
subst X: "%PROJECT_DIR%"
if errorlevel 1 (
    echo FAIL: Could not map Project to X:
    pause
    exit /b 1
)

:: 2. Set Env
echo [2] Setting Environment...
set PATH=Y:\bin;%PATH%
set FLUTTER_ROOT=Y:
set DART_SDK=Y:\bin\cache\dart-sdk

:: 3. Clear Hook Cache
echo [3] Clearing build cache...
if exist "X:\.dart_tool\hooks_runner" rd /s /q "X:\.dart_tool\hooks_runner"

:: 4. Run
echo [4] Launching Flutter Web...
echo     (Running from X: drive to avoid space issues)
pushd X:\
call flutter run -d chrome
popd

pause
