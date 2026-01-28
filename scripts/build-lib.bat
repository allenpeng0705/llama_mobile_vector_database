@echo off
setlocal enabledelayedexpansion

REM Build Lib Batch File for Windows
REM This script builds the core library using CMake
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
if "%NUM_CORES%"=="" set "NUM_CORES=0"
if "%NO_CLEAN%"=="" set "NO_CLEAN=false"
if "%KEEP_BUILD%"=="" set "KEEP_BUILD=false"

REM Determine number of cores to use
if "%NUM_CORES%"=="0" (
    for /f "tokens=*" %%a in ('wmic cpu get NumberOfLogicalProcessors ^| find /v "NumberOfLogicalProcessors"') do (
        set "NUM_CORES=%%a"
    )
)

REM Create build directory
set "BUILD_PATH=%PROJECT_ROOT%\%BUILD_DIR%"
if not exist "%BUILD_PATH%" mkdir "%BUILD_PATH%"

REM Navigate to build directory
cd "%BUILD_PATH%"

REM Run CMake configuration
if "%VERBOSE%"=="true" (
    echo Running CMake configuration with %NUM_CORES% cores...
)

cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=%BUILD_TYPE%
if %errorlevel% neq 0 (
    echo Error: CMake configuration failed
    exit /b %errorlevel%
)

REM Build the library
if "%VERBOSE%"=="true" (
    echo Building library with %NUM_CORES% cores...
)

cmake --build . --config %BUILD_TYPE% --parallel %NUM_CORES%
if %errorlevel% neq 0 (
    echo Error: Build failed
    exit /b %errorlevel%
)

REM Run tests if available
if exist "%BUILD_PATH%\tests" (
    if "%VERBOSE%"=="true" (
        echo Running tests...
    )
    ctest -C %BUILD_TYPE% -V
)

REM Navigate back to script directory
cd "%SCRIPT_DIR%"

echo Build completed successfully!
echo Library built in %BUILD_PATH%

endlocal
