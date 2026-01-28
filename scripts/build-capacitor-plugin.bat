@echo off
setlocal enabledelayedexpansion

REM Build Capacitor Plugin Batch File for Windows
REM This script builds the Capacitor plugin for iOS and Android
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

REM Set plugin directory
set "PLUGIN_DIR=%PROJECT_ROOT%\llama_mobile_vd-capacitor-plugin"
if not exist "%PLUGIN_DIR%" (
    echo Error: Plugin directory not found
    exit /b 1
)

echo === Building LlamaMobileVD Capacitor Plugin ===
echo Plugin directory: %PLUGIN_DIR%

REM Step 1: Verify iOS framework
echo.
echo Step 1: Verifying iOS framework...
set "IOS_FRAMEWORK=%PLUGIN_DIR%\ios\llama_mobile_vd.xcframework"
if not exist "%IOS_FRAMEWORK%" (
    echo iOS framework not found, searching for sources...
    
    REM Try sources in order of preference
    set "found_source="
    
    REM Preferred: dedicated iOS SDK
    set "IOS_SDK_SOURCE=%PROJECT_ROOT%\llama_mobile_vd-ios-SDK\ios\llama_mobile_vd.xcframework"
    if exist "%IOS_SDK_SOURCE%" (
        set "found_source=%IOS_SDK_SOURCE%"
    )
    
    REM Alternative: iOS directory
    if "!found_source!"=="" (
        set "IOS_ALT_SOURCE=%PROJECT_ROOT%\llama_mobile_vd-ios\ios\llama_mobile_vd.xcframework"
        if exist "%IOS_ALT_SOURCE%" (
            set "found_source=%IOS_ALT_SOURCE%"
        )
    )
    
    REM Fallback: Flutter SDK
    if "!found_source!"=="" (
        set "FLUTTER_IOS_SOURCE=%PROJECT_ROOT%\llama_mobile_vd-flutter-SDK\ios\llama_mobile_vd.xcframework"
        if exist "%FLUTTER_IOS_SOURCE%" (
            set "found_source=%FLUTTER_IOS_SOURCE%"
        )
    )
    
    if not "!found_source!"=="" (
        echo Copying iOS framework from !found_source!
        xcopy "!found_source!" "%IOS_FRAMEWORK%" /E /I /Y
        if !errorlevel! neq 0 (
            echo Error: Failed to copy iOS framework
            exit /b !errorlevel!
        )
        echo ✓ iOS framework copied
    ) else (
        echo Error: No iOS framework found at any potential sources
        echo Please ensure the iOS framework is built and available
        exit /b 1
    )
) else (
    echo ✓ iOS framework found
)

REM Step 2: Verify Android JNI libraries
echo.
echo Step 2: Verifying Android JNI libraries...
set "ANDROID_JNI=%PLUGIN_DIR%\android\src\main\jniLibs"
if not exist "%ANDROID_JNI%" ( mkdir "%ANDROID_JNI%" )

REM Check if JNI directory is empty
set "jni_empty=true"
for /d %%d in ("%ANDROID_JNI%\*") do (
    set "jni_empty=false"
    goto :jni_check_done
)
:jni_check_done

if "%jni_empty%"=="true" (
    echo Android JNI libraries not found, copying from Android SDK...
    set "ANDROID_SDK_JNI=%PROJECT_ROOT%\llama_mobile_vd-android-SDK\src\main\jniLibs"
    if exist "%ANDROID_SDK_JNI%" (
        xcopy "%ANDROID_SDK_JNI%" "%ANDROID_JNI%" /E /I /Y
        if !errorlevel! neq 0 (
            echo Error: Failed to copy Android JNI libraries
            exit /b !errorlevel!
        )
        echo ✓ Android JNI libraries copied
    ) else (
        echo Error: Android SDK JNI libraries not found
        exit /b 1
    )
) else (
    echo ✓ Android JNI libraries found
)

REM Step 3: Build TypeScript code
echo.
echo Step 3: Building TypeScript code...
cd "%PLUGIN_DIR%"

REM Install dependencies
if exist "package.json" (
    echo Installing dependencies...
    npm install
    if %errorlevel% neq 0 (
        echo Error: Failed to install dependencies
        exit /b %errorlevel%
    )
    
    REM Build TypeScript
    echo Building TypeScript...
    npm run build
    if %errorlevel% neq 0 (
        echo Error: TypeScript build failed
        exit /b %errorlevel%
    )
) else (
    echo Error: package.json not found
    exit /b 1
)

REM Step 4: Verify build artifacts
echo.
echo Step 4: Verifying build artifacts...

REM Check TypeScript build
if not exist "%PLUGIN_DIR%\dist" (
    echo Error: dist directory not found
    exit /b 1
)

if not exist "%PLUGIN_DIR%\dist\index.js" (
    echo Error: dist\index.js not found
    exit /b 1
)

if not exist "%PLUGIN_DIR%\dist\cjs\index.js" (
    echo Error: dist\cjs\index.js not found
    exit /b 1
)

echo ✓ TypeScript build verified

REM Check iOS plugin
if not exist "%PLUGIN_DIR%\ios\Plugin\LlamaMobileVDPlugin.swift" (
    echo Error: iOS plugin not found
    exit /b 1
)
echo ✓ iOS plugin verified

REM Check Android plugin
if not exist "%PLUGIN_DIR%\android\src\main\java\com\llamamobile\vd\LlamaMobileVD.java" (
    echo Error: Android plugin not found
    exit /b 1
)
echo ✓ Android plugin verified

REM Navigate back to script directory
cd "%SCRIPT_DIR%"

echo.
echo === Build Summary ===
echo Plugin directory: %PLUGIN_DIR%
echo TypeScript build: dist\
echo iOS plugin: ios\Plugin\
echo iOS framework: ios\llama_mobile_vd.xcframework\
echo Android plugin: android\src\main\java\com\llamamobile\vd\
echo Android JNI libs: android\src\main\jniLibs\

echo.
echo === Build completed successfully! ===
echo You can now use the plugin in your Capacitor project:
echo   cd your-capacitor-project
echo   npm install %PLUGIN_DIR%
echo   npx cap sync

echo.
echo === Important Notes ===
echo 1. Tests were skipped because they require native platform implementation
echo 2. The plugin is now ready for use on iOS and Android
echo 3. Web platform will use fallback implementation
echo 4. No source code was deleted during this process

echo.
endlocal
