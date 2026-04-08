@echo off
title Oracle SQL Assistant - Setup & Launch
color 0A

echo ============================================
echo   Oracle SQL / PL-SQL Assistant
echo ============================================
echo.

:: Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not on PATH.
    echo         Download from https://www.python.org/downloads/
    echo         Make sure to check "Add Python to PATH" during install.
    pause
    exit /b 1
)

:: Install dependencies
echo [1/3] Installing dependencies...
pip install flask requests --quiet
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies. Check your internet connection.
    pause
    exit /b 1
)
echo       Done.
echo.

echo [2/3] API key configured (hardcoded).
echo.

:: Get local IP
echo [3/3] Starting server...
echo.
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "127.0.0"') do (
    set LOCAL_IP=%%a
)
set LOCAL_IP=%LOCAL_IP: =%

echo ============================================
echo   Server running!
echo.
echo   Local:    http://localhost:8081
echo   Network:  http://%LOCAL_IP%:8081
echo.
echo   Any device on your network can access
echo   the app using the Network URL above.
echo.
echo   Press Ctrl+C to stop the server.
echo ============================================
echo.

python app.py
pause
