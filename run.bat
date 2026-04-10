@echo off
title CS Tutor - Llama 3.3 via Groq
color 0A

echo.
echo ====================================================
echo   CS Tutor - Auto Setup and Launch
echo ====================================================
echo.

:: -------------------------------------------------------
:: 1. Check if Python is installed, if not install it
:: -------------------------------------------------------
echo [1/4] Checking Python installation...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo   Python is NOT installed. Installing now...
    echo.

    :: Check if winget is available
    winget --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo   Installing Python via winget...
        winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent
        if %errorlevel% neq 0 (
            echo   [ERROR] winget install failed. Trying manual download...
            goto :manual_install
        )
        goto :refresh_path
    )

    :manual_install
    :: Download Python installer using PowerShell
    echo   Downloading Python installer...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe' -OutFile '%TEMP%\python_installer.exe'}" 2>nul

    if not exist "%TEMP%\python_installer.exe" (
        echo.
        echo   [ERROR] Failed to download Python.
        echo   Please download manually from https://www.python.org/downloads/
        echo   Make sure to check "Add Python to PATH" during install.
        echo.
        pause
        exit /b 1
    )

    echo   Running Python installer (this may take a minute)...
    "%TEMP%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_pip=1 Include_test=0
    if %errorlevel% neq 0 (
        echo.
        echo   [ERROR] Silent install failed. Launching interactive installer...
        echo   IMPORTANT: Check "Add Python to PATH" at the bottom of the installer!
        echo.
        "%TEMP%\python_installer.exe"
    )
    del "%TEMP%\python_installer.exe" 2>nul

    :refresh_path
    :: Refresh PATH so python is available in this session
    echo   Refreshing PATH...
    for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYSPATH=%%b"
    for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USRPATH=%%b"
    set "PATH=%SYSPATH%;%USRPATH%"

    :: Verify python works now
    python --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo.
        echo   [ERROR] Python installed but not found on PATH.
        echo   Please close this window, open a NEW command prompt, and run this .bat again.
        echo.
        pause
        exit /b 1
    )
)
for /f "tokens=*" %%v in ('python --version 2^>^&1') do echo        Found %%v
echo.

:: -------------------------------------------------------
:: 2. Upgrade pip
:: -------------------------------------------------------
echo [2/4] Updating pip...
python -m pip install --upgrade pip --quiet >nul 2>&1
if %errorlevel% neq 0 (
    python -m ensurepip --quiet >nul 2>&1
    python -m pip install --upgrade pip --quiet >nul 2>&1
)
echo        Done.
echo.

:: -------------------------------------------------------
:: 3. Install all dependencies
:: -------------------------------------------------------
echo [3/4] Installing dependencies...
python -m pip install --quiet requests 2>nul
echo        All dependencies installed.
echo.

:: -------------------------------------------------------
:: 4. Get local IP and launch
:: -------------------------------------------------------
echo [4/4] Starting server...
echo.

:: Get the local network IP
set LOCAL_IP=
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "127.0.0"') do (
    if not defined LOCAL_IP set "LOCAL_IP=%%a"
)
if defined LOCAL_IP set "LOCAL_IP=%LOCAL_IP: =%"

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
