@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   Text Prediction- Quick Start
echo ========================================
echo.

REM Check if running from correct directory
if not exist "text_completation" (
    echo Error: Please run this script from /home/satam/facial
    pause
    exit /b 1
)

if not exist "backend" (
    echo Error: Please run this script from /home/satam/facial
    pause
    exit /b 1
)

REM Start Backend
echo Starting Backend Server...
cd backend

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python not found!
    pause
    exit /b 1
)

REM Install requirements
echo Installing Python dependencies...
pip install -r requirements.txt >nul 2>&1

REM Run Flask in background
start "Backend Server" python app.py
echo ✓ Backend started
echo   URL: http://localhost:5000
echo.

REM Wait a moment for backend to start
timeout /t 2 /nobreak

REM Start Frontend
echo Starting Frontend Server...
cd ..\text_completation

REM Check if npm is installed
npm --version >nul 2>&1
if errorlevel 1 (
    echo Error: npm not found! Please install Node.js
    pause
    exit /b 1
)

REM Install dependencies
echo Installing Node dependencies...
call npm install >nul 2>&1

REM Run Vite in background
start "Frontend Server" npm run dev
echo ✓ Frontend started
echo   URL: http://localhost:5173
echo.

echo ========================================
echo Both servers are running!
echo ========================================
echo.
echo Backend:  http://localhost:5000
echo Frontend: http://localhost:5173
echo.
echo Close this window to stop the servers
echo.
pause
