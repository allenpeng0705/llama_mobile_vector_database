@echo off
setlocal enabledelayedexpansion

REM Build Flutter SDK Batch File for Windows
REM This script builds the Flutter SDK
REM Leverages config.env for centralized configuration

REM Get the directory containing this script
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."

REM Load configuration from config.env
if exist "%SCRIPT_DIR%config.env" (
    echo Loading configuration from %SCRIPT_DIR%config.env
    for /f "usebackq tokens=1,2 delims==" %%a in ("%SCRIPT_DIR%config.env") do (
        if not "%%a"=="" (
            if not "%%a"=="[core]" if not "%%a"=="[ios]" if not "%%a"=="[android]" if not "%%a"=="[flutter]" if not "%%a"=="[react-native]" if not "%%a"=="[capacitor]" (
                set "%%a=%%b"
            )
        )
    )
) else (
    echo Warning: config.env not found, using default values
)

REM Set default values if not set
if "%BUILD_TYPE%"=="" set "BUILD_TYPE=Release"
if "%FLUTTER_SDK_PATH%"=="" set "FLUTTER_SDK_PATH=%USERPROFILE%\flutter"
if "%FORCE_REBUILD%"=="" set "FORCE_REBUILD=false"
if "%CLEAN_BUILD%"=="" set "CLEAN_BUILD=false"

REM Verify Flutter SDK path
if not exist "%FLUTTER_SDK_PATH%\bin\flutter.bat" (
    echo Error: Flutter SDK not found at %FLUTTER_SDK_PATH%
    echo Please set FLUTTER_SDK_PATH in config.env
    exit /b 1
)

REM Add Flutter to PATH
set "PATH=%FLUTTER_SDK_PATH%\bin;%PATH%"

REM Build the Android library first
if exist "%SCRIPT_DIR%build-android-lib.bat" (
    echo Building Android library first...
    call "%SCRIPT_DIR%build-android-lib.bat"
    if %errorlevel% neq 0 (
        echo Error: Failed to build Android library
        exit /b %errorlevel%
    )
)

REM Navigate to Flutter SDK directory
set "FLUTTER_SDK_DIR=%PROJECT_ROOT%\llama_mobile_vd-flutter-SDK"
if not exist "%FLUTTER_SDK_DIR%" (
    echo Error: Flutter SDK directory not found
    exit /b 1
)

cd "%FLUTTER_SDK_DIR%"

REM Run Flutter build
if "%CLEAN_BUILD%"=="true" (
    echo Cleaning Flutter build...
    flutter clean
)

echo Building Flutter SDK...
flutter pub get
if %errorlevel% neq 0 (
    echo Error: Flutter pub get failed
    exit /b %errorlevel%
)

REM Build for Android
if exist "%FLUTTER_SDK_DIR%\android" (
    echo Building Flutter SDK for Android...
    flutter build aar
    if %errorlevel% neq 0 (
        echo Error: Flutter Android build failed
        exit /b %errorlevel%
    )
)

REM Navigate back to script directory
cd "%SCRIPT_DIR%"

echo Flutter SDK build completed successfully!
echo SDK built in %FLUTTER_SDK_DIR%

endlocal
