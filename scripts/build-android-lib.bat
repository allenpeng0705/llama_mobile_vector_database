@echo off
setlocal enabledelayedexpansion

REM Build Android Lib Batch File for Windows
REM This script builds the Android library using CMake and NDK
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
if "%VERBOSE%"=="" set "VERBOSE=false"
if "%BUILD_DIR%"=="" set "BUILD_DIR=build"
if "%ANDROID_HOME%"=="" set "ANDROID_HOME=%USERPROFILE%\AppData\Local\Android\Sdk"
if "%ANDROID_PLATFORM%"=="" set "ANDROID_PLATFORM=android-24"
if "%ARCHITECTURES%"=="" set "ARCHITECTURES=arm64-v8a x86_64"

REM Auto-detect NDK path if not set
if "%ANDROID_NDK_PATH%"=="" (
    for /d %%d in ("%ANDROID_HOME%\ndk\*") do (
        set "ANDROID_NDK_PATH=%%d"
        goto :ndk_found
    )
    :ndk_found
    if "%ANDROID_NDK_PATH%"=="" (
        echo Error: Android NDK not found
        exit /b 1
    )
)

echo Using Android NDK: %ANDROID_NDK_PATH%

REM Create build directory
set "BUILD_PATH=%PROJECT_ROOT%\%BUILD_DIR%\android"
if not exist "%BUILD_PATH%" mkdir "%BUILD_PATH%"

REM Build for each architecture
for %%a in (%ARCHITECTURES%) do (
    echo Building for %%a...
    set "ARCH_BUILD_PATH=%BUILD_PATH%\%%a"
    if not exist "!ARCH_BUILD_PATH!" mkdir "!ARCH_BUILD_PATH!"
    
    cd "!ARCH_BUILD_PATH!"
    
    REM Run CMake configuration
    cmake ../../.. -G "Ninja" ^
        -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK_PATH%\build\cmake\android.toolchain.cmake ^
        -DANDROID_ABI=%%a ^
        -DANDROID_PLATFORM=%ANDROID_PLATFORM% ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE%
    if !errorlevel! neq 0 (
        echo Error: CMake configuration failed for %%a
        exit /b !errorlevel!
    )
    
    REM Build the library
    cmake --build . --config %BUILD_TYPE%
    if !errorlevel! neq 0 (
        echo Error: Build failed for %%a
        exit /b !errorlevel!
    )
)

REM Copy built libraries to android directory
set "ANDROID_LIB_PATH=%PROJECT_ROOT%\llama_mobile_vd-android\libs"
if not exist "%ANDROID_LIB_PATH%" mkdir "%ANDROID_LIB_PATH%"

for %%a in (%ARCHITECTURES%) do (
    set "LIB_DIR=%ANDROID_LIB_PATH%\%%a"
    if not exist "!LIB_DIR!" mkdir "!LIB_DIR!"
    copy "%BUILD_PATH%\%%a\libllama_mobile_vd.a" "!LIB_DIR!" > nul
    if !errorlevel! neq 0 (
        echo Error: Failed to copy library for %%a
        exit /b !errorlevel!
    )
)

REM Navigate back to script directory
cd "%SCRIPT_DIR%"

echo Android library build completed successfully!
echo Libraries copied to %ANDROID_LIB_PATH%

endlocal
