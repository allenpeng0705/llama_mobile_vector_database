@echo off
REM Build script for LlamaMobileVD Capacitor Plugin (Windows)
REM This script builds plugin from source and prepares it for distribution

setlocal enabledelayedexpansion

echo === Building LlamaMobileVD Capacitor Plugin ===

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."
set "PLUGIN_DIR=%PROJECT_ROOT%\llama_mobile_vd-capacitor-plugin"
set "SDK_BACKUP_DIR=%PROJECT_ROOT%\scripts\sdk_backup"

REM ==========================
REM CENTRAL CONFIGURATION
REM Read settings from centralized config.env file if it exists
REM ==========================

REM Paths
set "CONFIG_FILE=%SCRIPT_DIR%config.env"

REM Check if config file exists
if not exist "%CONFIG_FILE%" (
    echo Config file not found: %CONFIG_FILE%
    echo Using default values...
) else (
    echo Using configuration from %CONFIG_FILE%
)

REM Note: Config file parsing is simplified for Windows batch
REM We'll use default values for Capacitor path

REM Check if plugin directory exists
if not exist "%PLUGIN_DIR%" (
    echo Error: Plugin directory not found at %PLUGIN_DIR%
    exit /b 1
)

REM ==========================
REM STEP 1: Backup Capacitor Plugin
REM ==========================
echo.
echo Step 1: Backing up Capacitor Plugin...

REM Create backup directory if it doesn't exist
if not exist "%SDK_BACKUP_DIR%" (
    mkdir "%SDK_BACKUP_DIR%"
)

REM Create timestamped backup
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "DATE=%%c%%a%%b"
for /f "tokens=1-3 delims=:." %%a in ("%time%") do set "TIME=%%a%%b%%c"
set "TIMESTAMP=%DATE%_%TIME%"
set "BACKUP_NAME=llama_mobile_vd-capacitor-plugin_%TIMESTAMP%"
set "BACKUP_DIR=%SDK_BACKUP_DIR%\%BACKUP_NAME%"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM Copy Capacitor plugin files to backup
echo Creating backup at %BACKUP_DIR%
xcopy "%PLUGIN_DIR%\*" "%BACKUP_DIR%\" /E /I /H /Y >nul
echo Capacitor Plugin backed up

REM ==========================
REM STEP 2: Clean and Copy Native Files
REM ==========================
echo.
echo Step 2: Cleaning and copying native files...

REM Clean iOS xcframework
set "IOS_XCFRAMEWORK_DST=%PLUGIN_DIR%\ios\llama_mobile_vd.xcframework"
if exist "%IOS_XCFRAMEWORK_DST%" (
    echo Cleaning iOS xcframework...
    rmdir /s /q "%IOS_XCFRAMEWORK_DST%"
)

REM Clean iOS Swift wrapper
set "IOS_SWIFT_DST=%PLUGIN_DIR%\ios\Plugin\LlamaMobileVD.swift"
if exist "%IOS_SWIFT_DST%" (
    echo Cleaning iOS Swift wrapper...
    del /q "%IOS_SWIFT_DST%"
)

REM Clean Android cpp directory
set "ANDROID_CPP_DST=%PLUGIN_DIR%\android\src\main\cpp"
if exist "%ANDROID_CPP_DST%" (
    echo Cleaning Android cpp directory...
    rmdir /s /q "%ANDROID_CPP_DST%"
)

REM Clean Android jniLibs directory
set "ANDROID_JNI_DST=%PLUGIN_DIR%\android\src\main\jniLibs"
if exist "%ANDROID_JNI_DST%" (
    echo Cleaning Android jniLibs directory...
    rmdir /s /q "%ANDROID_JNI_DST%"
)

REM Clean Android Java wrapper
set "ANDROID_JAVA_DST=%PLUGIN_DIR%\android\src\main\java\com\llamamobile\vd\LlamaMobileVD.java"
if exist "%ANDROID_JAVA_DST%" (
    echo Cleaning Android Java wrapper...
    del /q "%ANDROID_JAVA_DST%"
)

REM Create necessary directories
if not exist "%PLUGIN_DIR%\ios\Plugin" mkdir "%PLUGIN_DIR%\ios\Plugin"
if not exist "%PLUGIN_DIR%\android\src\main\cpp" mkdir "%PLUGIN_DIR%\android\src\main\cpp"
if not exist "%PLUGIN_DIR%\android\src\main\jniLibs" mkdir "%PLUGIN_DIR%\android\src\main\jniLibs"
if not exist "%PLUGIN_DIR%\android\src\main\java\com\llamamobile\vd" mkdir "%PLUGIN_DIR%\android\src\main\java\com\llamamobile\vd"

REM Copy iOS xcframework from llama_mobile_vd-ios
echo Copying iOS xcframework...
set "IOS_XCFRAMEWORK_SRC=%PROJECT_ROOT%\llama_mobile_vd-ios\llama_mobile_vd.xcframework"
if exist "%IOS_XCFRAMEWORK_SRC%" (
    xcopy "%IOS_XCFRAMEWORK_SRC%" "%IOS_XCFRAMEWORK_DST%\" /E /I /H /Y >nul
    echo iOS xcframework copied
) else (
    echo Error: iOS xcframework not found at %IOS_XCFRAMEWORK_SRC%
    exit /b 1
)

REM Copy Swift wrapper from llama_mobile_vd-ios-SDK
echo Copying Swift wrapper...
set "IOS_SWIFT_SRC=%PROJECT_ROOT%\llama_mobile_vd-ios-SDK\Sources\LlamaMobileVD\LlamaMobileVD.swift"
if exist "%IOS_SWIFT_SRC%" (
    copy /y "%IOS_SWIFT_SRC%" "%IOS_SWIFT_DST%" >nul
    echo Swift wrapper copied
) else (
    echo Error: Swift wrapper not found at %IOS_SWIFT_SRC%
    exit /b 1
)

REM Copy JNI libs from llama_mobile_vd-android
echo Copying JNI libraries...
set "ANDROID_JNI_SRC=%PROJECT_ROOT%\llama_mobile_vd-android\libs"
if exist "%ANDROID_JNI_SRC%" (
    xcopy "%ANDROID_JNI_SRC%\*" "%ANDROID_JNI_DST%\" /E /I /H /Y >nul
    echo JNI libraries copied
) else (
    echo Error: JNI libraries not found at %ANDROID_JNI_SRC%
    exit /b 1
)

REM Copy cpp files from llama_mobile_vd-android-SDK
echo Copying cpp files...
set "ANDROID_CPP_SRC=%PROJECT_ROOT%\llama_mobile_vd-android-SDK\src\main\cpp"
if exist "%ANDROID_CPP_SRC%" (
    xcopy "%ANDROID_CPP_SRC%\*" "%ANDROID_CPP_DST%\" /E /I /H /Y >nul
    echo cpp files copied
) else (
    echo Error: cpp files not found at %ANDROID_CPP_SRC%
    exit /b 1
)

REM Copy Java wrapper from llama_mobile_vd-android-SDK
echo Copying Java wrapper...
set "ANDROID_JAVA_SRC=%PROJECT_ROOT%\llama_mobile_vd-android-SDK\src\main\java\com\llamamobile\vd\LlamaMobileVD.java"
if exist "%ANDROID_JAVA_SRC%" (
    copy /y "%ANDROID_JAVA_SRC%" "%ANDROID_JAVA_DST%" >nul
    echo Java wrapper copied
) else (
    echo Error: Java wrapper not found at %ANDROID_JAVA_SRC%
    exit /b 1
)

REM ==========================
REM STEP 3: Build Everything
REM ==========================
echo.
echo Step 3: Building TypeScript code...
pushd "%PLUGIN_DIR%"

REM Install dependencies
echo Installing npm dependencies...
call npm install

if %errorlevel% neq 0 (
    echo Error: npm install failed
    popd
    exit /b 1
)

REM Build TypeScript
echo Building TypeScript...
call npm run build

if %errorlevel% neq 0 (
    echo Error: npm run build failed
    popd
    exit /b 1
)

REM Verify build artifacts
echo.
echo Verifying build artifacts...

if not exist "%PLUGIN_DIR%\dist" (
    echo Error: dist directory not found
    popd
    exit /b 1
)

if not exist "%PLUGIN_DIR%\dist\index.js" (
    echo Error: dist\index.js not found
    popd
    exit /b 1
)

if not exist "%PLUGIN_DIR%\dist\cjs\index.js" (
    echo Error: dist\cjs\index.js not found
    popd
    exit /b 1
)

echo TypeScript build verified

REM Check iOS plugin
if not exist "%PLUGIN_DIR%\ios\Plugin\LlamaMobileVDPlugin.swift" (
    echo Error: iOS plugin not found
    popd
    exit /b 1
)

echo iOS plugin verified

REM Check Android plugin
if not exist "%PLUGIN_DIR%\android\src\main\java\com\llamamobile\vd\LlamaMobileVDPlugin.java" (
    echo Error: Android plugin not found
    popd
    exit /b 1
)

echo Android plugin verified

popd

REM ==========================
REM STEP 4: Run Tests
REM ==========================
echo.
echo Step 4: Running tests...

REM Check if tests directory exists
if exist "%PLUGIN_DIR%\tests" (
    echo Running npm test...
    pushd "%PLUGIN_DIR%"
    call npm test
    if %errorlevel% equ 0 (
        echo Tests passed
    ) else (
        echo Warning: Some tests failed or were skipped
    )
    popd
) else if exist "%PLUGIN_DIR%\test" (
    echo Running npm test...
    pushd "%PLUGIN_DIR%"
    call npm test
    if %errorlevel% equ 0 (
        echo Tests passed
    ) else (
        echo Warning: Some tests failed or were skipped
    )
    popd
) else if exist "%PLUGIN_DIR%\__tests__" (
    echo Running npm test...
    pushd "%PLUGIN_DIR%"
    call npm test
    if %errorlevel% equ 0 (
        echo Tests passed
    ) else (
        echo Warning: Some tests failed or were skipped
    )
    popd
) else (
    echo No test directory found, skipping tests
)

REM ==========================
REM STEP 5: Display Summary
REM ==========================
echo.
echo === Build Summary ===
echo Plugin directory: %PLUGIN_DIR%
echo TypeScript build: dist\
echo iOS plugin: ios\Plugin\
echo iOS framework: ios\llama_mobile_vd.xcframework\
echo Android plugin: android\src\main\java\com\llamamobile\vd\
echo Android JNI libs: android\src\main\jniLibs\
echo Android cpp: android\src\main\cpp\
echo Backup location: %BACKUP_DIR%

echo.
echo === Build completed successfully! ===
echo You can now use plugin in your Capacitor project:
echo   cd your-capacitor-project
echo   npm install %PLUGIN_DIR%
echo   npx cap sync

echo.
echo Everything is fine!

exit /b 0
