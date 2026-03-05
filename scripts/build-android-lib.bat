@echo off
REM Android Core Library Build Script for Llama Mobile VD (Windows)
REM This script builds a pure C++ Android library without any Java/Kotlin wrappers.
REM The library will contain only the C++ library and header files.

setlocal enabledelayedexpansion

REM ==========================
REM CONFIGURATION
REM ==========================

set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."
set "CONFIG_FILE=%SCRIPT_DIR%config.env"

REM Check if config file exists
if not exist "%CONFIG_FILE%" (
    echo ❌ Config file not found: %CONFIG_FILE%
    exit /b 1
)

REM Function to read value from config file
REM Note: This is a simplified version - Windows batch doesn't have easy config file parsing
REM We'll use default values

REM ==========================
REM DEFAULT SETTINGS
REM ==========================
set "DEFAULT_BUILD_TYPE=Release"
set "DEFAULT_ANDROID_PLATFORM=android-24"
set "DEFAULT_ARCHITECTURES=arm64-v8a x86_64"

REM ==========================
REM SCRIPT CONFIGURATION
REM ==========================
if "%BUILD_TYPE%"=="" set "BUILD_TYPE=%DEFAULT_BUILD_TYPE%"
if "%ANDROID_PLATFORM%"=="" set "ANDROID_PLATFORM=%DEFAULT_ANDROID_PLATFORM%"
if "%ARCHITECTURES%"=="" set "ARCHITECTURES=%DEFAULT_ARCHITECTURES%"

REM ==========================
REM PROJECT PATHS
REM ==========================
set "WRAPPER_DIR=%PROJECT_ROOT%\lib\wrapper"
set "CORE_LLAMA_DIR=%PROJECT_ROOT%\lib\llama_cpp\quiverdb"
set "OUTPUT_DIR=%PROJECT_ROOT%\llama_mobile_vd-android"
set "LIBRARY_NAME=libllama_mobile_vd.a"

REM ==========================
REM VALIDATION
REM ==========================

REM Validate build type
if /i not "%BUILD_TYPE%"=="Debug" (
    if /i not "%BUILD_TYPE%"=="Release" (
        echo ❌ Invalid build type: %BUILD_TYPE%
        echo Valid build types: Debug, Release
        exit /b 1
    )
)

REM Validate architectures
set "VALID_ARCHITECTURES=arm64-v8a x86_64 armeabi-v7a x86"
for %%a in (%ARCHITECTURES%) do (
    set "VALID=0"
    for %%v in (%VALID_ARCHITECTURES%) do (
        if "%%a"=="%%v" set "VALID=1"
    )
    if "!VALID!"=="0" (
        echo ❌ Invalid architecture: %%a
        echo Valid architectures: %VALID_ARCHITECTURES%
        exit /b 1
    )
)

REM Check for required environment variables
echo === Checking Environment Variables ===

if "%ANDROID_HOME%"=="" (
    echo ❌ Error: ANDROID_HOME environment variable not set
    echo Please set ANDROID_HOME to your Android SDK installation directory
    exit /b 1
)
echo ANDROID_HOME: %ANDROID_HOME%

if "%JAVA_HOME%"=="" (
    echo ❌ Error: JAVA_HOME environment variable not set
    echo Please set JAVA_HOME to your Java JDK installation directory
    exit /b 1
)
echo JAVA_HOME: %JAVA_HOME%

REM Check for required dependencies
echo.
echo === Checking Dependencies ===

REM Check for Android NDK
echo Checking for Android NDK...
if "%ANDROID_NDK_PATH%"=="" (
    REM Try to find NDK in ANDROID_HOME
    for /d %%d in ("%ANDROID_HOME%\ndk\*") do (
        set "ANDROID_NDK_PATH=%%d"
    )
)

if not exist "%ANDROID_NDK_PATH%" (
    echo ❌ Error: Android NDK not found
    echo Please install Android NDK or set ANDROID_NDK_PATH environment variable
    exit /b 1
)
echo %ANDROID_NDK_PATH%

REM Check for CMake
echo Checking for CMake...
where cmake >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: CMake not found
    echo Please install CMake and add it to your PATH
    exit /b 1
)
where cmake

REM ==========================
REM BUILD PROCESS
REM ==========================
echo.
echo === Building Android Core Library ===
echo Build Type: %BUILD_TYPE%
echo Android Platform: %ANDROID_PLATFORM%
echo Architectures: %ARCHITECTURES%
echo Output Directory: %OUTPUT_DIR%

REM Clean any existing build directories - preserving README.md
if exist "%OUTPUT_DIR%\README.md" (
    REM Save the README.md file temporarily
    move "%OUTPUT_DIR%\README.md" "%PROJECT_ROOT%\temp_README.md" >nul
)

if exist "%OUTPUT_DIR%" (
    rmdir /s /q "%OUTPUT_DIR%"
)
mkdir "%OUTPUT_DIR%"

REM Restore the README.md if it was saved
if exist "%PROJECT_ROOT%\temp_README.md" (
    move "%PROJECT_ROOT%\temp_README.md" "%OUTPUT_DIR%\README.md" >nul
)

if exist "%PROJECT_ROOT%\build-android" (
    rmdir /s /q "%PROJECT_ROOT%\build-android"
)
mkdir "%PROJECT_ROOT%\build-android"

REM Create output directories for each architecture
mkdir "%OUTPUT_DIR%\libs"
for %%a in (%ARCHITECTURES%) do (
    mkdir "%OUTPUT_DIR%\libs\%%a"
)

REM Copy header files
echo.
echo === Copying Header Files ===
mkdir "%OUTPUT_DIR%\include"
copy "%WRAPPER_DIR%\include\llama_mobile_vd_wrapper.h" "%OUTPUT_DIR%\include\" >nul
echo ✓ Copied llama_mobile_vd_wrapper.h to %OUTPUT_DIR%\include\
copy "%WRAPPER_DIR%\include\llama_mobile_vd_version.h" "%OUTPUT_DIR%\include\" >nul
echo ✓ Copied llama_mobile_vd_version.h to %OUTPUT_DIR%\include\

REM Build the C++ wrapper library for each architecture
cd /d "%WRAPPER_DIR%"
echo.
echo === Building C++ Wrapper Library ===

REM Function to build for each architecture
for %%a in (%ARCHITECTURES%) do (
    call :build_android_library %%a
)

if %errorlevel% neq 0 (
    echo.
    echo ❌ Build failed!
    exit /b 1
)

REM ==========================
REM VERIFICATION
REM ==========================
echo.
echo === Verifying Build Results ===

REM Check if all libraries were built successfully
set "ALL_SUCCESS=1"
for %%a in (%ARCHITECTURES%) do (
    set "LIBRARY_PATH=%OUTPUT_DIR%\libs\%%a\%LIBRARY_NAME%"
    if exist "!LIBRARY_PATH!" (
        echo ✓ Library exists: !LIBRARY_PATH!
    ) else (
        echo ❌ Library missing: !LIBRARY_PATH!
        set "ALL_SUCCESS=0"
    )
)

if "%ALL_SUCCESS%"=="1" (
    echo.
    echo ✅ Android Core Library built successfully!
    echo Output location: %OUTPUT_DIR%
    echo Architectures built: %ARCHITECTURES%
    echo Header files: %OUTPUT_DIR%\include\
) else (
    echo.
    echo ❌ Android Core Library build failed!
    exit /b 1
)

REM Clean up temporary build directories
for /d %%d in ("%PROJECT_ROOT%\build-android-*") do (
    rmdir /s /q "%%d" 2>nul
)

exit /b 0

REM ==========================
REM FUNCTIONS
REM ==========================

:build_android_library
set "ARCH=%~1"
set "BUILD_DIR=%PROJECT_ROOT%\build-android-%ARCH%"
set "OUTPUT_ARCH_DIR=%OUTPUT_DIR%\libs\%ARCH%"

echo.
echo Building for %ARCH%...

REM Create build directory
if exist "%BUILD_DIR%" (
    rmdir /s /q "%BUILD_DIR%"
)
mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

REM Run CMake configuration
REM Note: 16 KB page size alignment is automatically applied via CMakeLists.txt
REM This is required for Android 15 (API level 35) and higher
cmake "%WRAPPER_DIR%" ^
    -G "Unix Makefiles" ^
    -DCMAKE_TOOLCHAIN_FILE="%ANDROID_NDK_PATH%\build\cmake\android.toolchain.cmake" ^
    -DANDROID_ABI=%ARCH% ^
    -DANDROID_PLATFORM=%ANDROID_PLATFORM% ^
    -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DANDROID_STL=c++_static ^
    -DANDROID_ARM_MODE=arm ^
    -DANDROID_ARM_NEON=TRUE

if %errorlevel% neq 0 (
    echo ❌ CMake configuration failed for %ARCH%
    exit /b 1
)

REM Build the library
cmake --build . --config %BUILD_TYPE%

if %errorlevel% neq 0 (
    echo ❌ Build failed for %ARCH%
    exit /b 1
)

REM Copy the built library to the output directory
if exist "libllama_mobile_vd.a" (
    copy "libllama_mobile_vd.a" "%OUTPUT_ARCH_DIR%\%LIBRARY_NAME%" >nul
    echo ✓ Built and copied %LIBRARY_NAME% for %ARCH%
) else (
    echo ❌ Error: libllama_mobile_vd.a not found for %ARCH%
    exit /b 1
)

exit /b 0
