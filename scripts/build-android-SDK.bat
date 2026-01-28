@echo off
setlocal enabledelayedexpansion

REM Build Android SDK Batch File for Windows
REM This script builds the Android SDK using Gradle
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
if "%ANDROID_HOME%"=="" set "ANDROID_HOME=%USERPROFILE%\AppData\Local\Android\Sdk"
if "%JAVA_HOME%"=="" set "JAVA_HOME=%ProgramFiles%\Java\jdk-17"

REM Set Android SDK and NDK paths for Gradle
set "ANDROID_SDK_ROOT=%ANDROID_HOME%"

REM Build the Android library first
if exist "%SCRIPT_DIR%build-android-lib.bat" (
    echo Building Android library first...
    call "%SCRIPT_DIR%build-android-lib.bat"
    if %errorlevel% neq 0 (
        echo Error: Failed to build Android library
        exit /b %errorlevel%
    )
)

REM Navigate to Android SDK directory
set "ANDROID_SDK_DIR=%PROJECT_ROOT%\llama_mobile_vd-android-SDK"
if not exist "%ANDROID_SDK_DIR%" (
    echo Error: Android SDK directory not found
    exit /b 1
)

cd "%ANDROID_SDK_DIR%"

REM Run Gradle build
if "%BUILD_TYPE%"=="Debug" (
    echo Building Android SDK (Debug)...
    gradlew assembleDebug
) else (
    echo Building Android SDK (Release)...
    gradlew assembleRelease
)

if %errorlevel% neq 0 (
    echo Error: Gradle build failed
    exit /b %errorlevel%
)

REM Navigate back to script directory
cd "%SCRIPT_DIR%"

echo Android SDK build completed successfully!
echo SDK built in %ANDROID_SDK_DIR%\build

endlocal
