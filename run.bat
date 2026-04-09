@echo off
title CS Tutor - Llama 3.3 via Groq
color 0A

echo.
echo ====================================================
echo   CS Tutor - Auto Setup and Launch
echo ====================================================
echo.

:: -------------------------------------------------------
:: 1. Check if Python is installed
:: -------------------------------------------------------
echo [1/4] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo   [ERROR] Python is NOT installed or not on PATH.
    echo.
    echo   Fix: Download Python from https://www.python.org/downloads/
    echo        During install, CHECK the box "Add Python to PATH"
    echo        Then re-run this file.
    echo.
    pause
    exit /b 1
)
for /f "tokens=2" %%v in ('python --version 2^>^&1') do echo        Found Python %%v
echo.

:: -------------------------------------------------------
:: 2. Upgrade pip silently
:: -------------------------------------------------------
echo [2/4] Updating pip...
python -m pip install --upgrade pip --quiet >nul 2>&1
echo        Done.
echo.

:: -------------------------------------------------------
:: 3. Install all dependencies
:: -------------------------------------------------------
echo [3/4] Installing dependencies...

:: Create requirements file on the fly
echo.>"%~dp0\requirements.txt"
(
echo # CS Tutor Dependencies - auto generated
) > "%~dp0\requirements.txt"

:: The app uses only Python standard library (http.server, urllib, json)
:: No pip packages needed! But install these just in case user extends it:
python -m pip install --quiet requests 2>nul
echo        All dependencies installed.
echo.

:: -------------------------------------------------------
:: 4. Get local IP and launch
:: -------------------------------------------------------
echo [4/4] Starting server...
echo.

:: Get ALL local network IPs (WiFi + Ethernet)
set LOCAL_IP=
set IP_COUNT=0
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "127.0.0"') do (
    set "TEMP_IP=%%a"
    call set "TEMP_IP=%%TEMP_IP: =%%"
    if not defined LOCAL_IP call set "LOCAL_IP=%%TEMP_IP%%"
    set /a IP_COUNT+=1
)

echo ====================================================
echo.
echo   CS Tutor is RUNNING!
echo.
echo ====================================================
echo.
echo   YOUR APP IS LIVE AT:
echo.
echo      http://localhost:8008
echo.
if defined LOCAL_IP (
echo   ----------------------------------------------------
echo   SHARE THIS WITH OTHER DEVICES ON YOUR NETWORK:
echo.
echo      http://%LOCAL_IP%:8008
echo.
echo   ----------------------------------------------------
) else (
echo   [!] Could not detect network IP.
echo       Check your WiFi/Ethernet connection.
echo.
)
echo   Subjects: OS + C  ^|  Oracle SQL/PLSQL  ^|  React
echo   Models:   Llama 3.3 70B  ^|  GPT-OSS 120B
echo.
echo   Press Ctrl+C to stop the server.
echo.
echo ====================================================
echo.

:: -------------------------------------------------------
:: Allow through Windows Firewall (requires admin)
:: -------------------------------------------------------
netsh advfirewall firewall show rule name="CS Tutor Port 8008" >nul 2>&1
if %errorlevel% neq 0 (
    echo   Adding firewall rule for port 8008...
    netsh advfirewall firewall add rule name="CS Tutor Port 8008" dir=in action=allow protocol=TCP localport=8008 >nul 2>&1
    if %errorlevel% neq 0 (
        echo   [!] Could not add firewall rule. Run this .bat as Administrator
        echo       if other devices on your network can't connect.
    ) else (
        echo   Firewall rule added successfully.
    )
    echo.
)

:: -------------------------------------------------------
:: Launch the app
:: -------------------------------------------------------
cd /d "%~dp0"
python app.py

echo.
echo Server stopped.
pause
