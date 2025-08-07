@echo off
echo.
echo ================================
echo  Fuel Route Admin Panel Setup
echo ================================
echo.

echo [1/3] Checking dependencies...
npm list next >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Dependencies not found. Please run 'npm install' first.
    pause
    exit /b 1
)
echo ✓ Dependencies are installed

echo.
echo [2/3] Checking configuration...
if not exist "lib\firebase-config.ts" (
    echo Error: Firebase configuration not found.
    echo Please configure your Firebase settings in lib\firebase-config.ts
    pause
    exit /b 1
)
echo ✓ Configuration files found

echo.
echo [3/3] Starting development server...
echo.
echo Opening admin panel at http://localhost:3000
echo Press Ctrl+C to stop the server
echo.

npx next dev

echo.
echo Server stopped.
pause
