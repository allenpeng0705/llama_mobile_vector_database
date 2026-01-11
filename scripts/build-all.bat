@echo off
setlocal EnableDelayedExpansion

REM Build all SDKs for Llama Mobile VD on Windows

REM Paths
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "PROJECT_ROOT=%SCRIPT_DIR%\.."
set "CONFIG_FILE=%SCRIPT_DIR%\config.env"

REM Check if config file exists
if not exist "%CONFIG_FILE%" (
    echo ■■■ Config file not found: %CONFIG_FILE%
    echo Please run the scripts from the project root directory
    exit /b 1
)

echo === Building All Llama Mobile VD SDKs on Windows ===

REM Step 1: Build core library
echo.
echo Step 1: Building Core Library
echo =============================
if exist "%SCRIPT_DIR%\build-lib.bat" (
    call "%SCRIPT_DIR%\build-lib.bat"
    if errorlevel 1 (
        echo ■■■ Failed to build core library
        exit /b 1
    )
) else (
    echo ■■■ build-lib.bat not found
    exit /b 1
)

REM Step 2: Build Android SDK
echo.
echo Step 2: Building Android SDK
echo ============================
if exist "%SCRIPT_DIR%\build-android.bat" (
    call "%SCRIPT_DIR%\build-android.bat"
    if errorlevel 1 (
        echo ■■■ Failed to build Android SDK
        exit /b 1
    )
) else (
    echo ■■■ build-android.bat not found
    exit /b 1
)

REM Step 3: Build Flutter SDK
echo.
echo Step 3: Building Flutter SDK
echo ============================
if exist "%SCRIPT_DIR%\build-flutter-SDK.bat" (
    call "%SCRIPT_DIR%\build-flutter-SDK.bat"
    if errorlevel 1 (
        echo ■■■ Failed to build Flutter SDK
        exit /b 1
    )
) else (
    echo ■■■ build-flutter-SDK.bat not found
    exit /b 1
)

REM Step 4: Build React Native SDK
echo.
echo Step 4: Building React Native SDK
echo ================================
if exist "%SCRIPT_DIR%\build-rn-SDK.bat" (
    call "%SCRIPT_DIR%\build-rn-SDK.bat"
    if errorlevel 1 (
        echo ■■■ Failed to build React Native SDK
        exit /b 1
    )
) else (
    echo ■■■ build-rn-SDK.bat not found
    exit /b 1
)

REM Step 5: Build Capacitor Plugin
echo.
echo Step 5: Building Capacitor Plugin
echo ===============================
if exist "%SCRIPT_DIR%\build-capacitor-plugin.bat" (
    call "%SCRIPT_DIR%\build-capacitor-plugin.bat"
    if errorlevel 1 (
        echo ■■■ Failed to build Capacitor Plugin
        exit /b 1
    )
) else (
    echo ■■■ build-capacitor-plugin.bat not found
    exit /b 1
)

REM Step 6: iOS Build Information
echo.
echo Step 6: iOS Build Information
echo ============================
if exist "%SCRIPT_DIR%\build-ios.bat" (
    call "%SCRIPT_DIR%\build-ios.bat"
) else (
    echo ■■■ build-ios.bat not found
    exit /b 1
)

echo.
echo === All SDK Builds Completed (Android Components) ===
echo.
echo Summary of builds:
echo - Core Library: Built successfully
echo - Android SDK: Built successfully
echo - Flutter SDK: Built successfully (Android)
echo - React Native SDK: Built successfully (Android)
echo - Capacitor Plugin: Built successfully (Android)
echo - iOS SDK: Requires macOS for full build
echo.
echo Next steps:
echo 1. For complete iOS support, build the iOS framework on macOS
2. Run tests for each SDK
3. Integrate with your application
4. For deployment, refer to the project documentation
exit /b 0