@echo off
REM Building Flutter SDK for Llama Mobile Vector Database (Windows)

setlocal enabledelayedexpansion

echo Building Flutter SDK for Llama Mobile Vector Database...

REM Get absolute path to project root
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."
set "FLUTTER_SDK_DIR=%PROJECT_ROOT%\llama_mobile_vd-flutter-SDK"
set "SDK_BACKUP_DIR=%PROJECT_ROOT%\scripts\sdk_backup"
set "IOS_SDK_DIR=%PROJECT_ROOT%\llama_mobile_vd-ios-SDK"
set "ANDROID_SDK_DIR=%PROJECT_ROOT%\llama_mobile_vd-android-SDK"

REM Create scripts directory if it doesn't exist
if not exist "%PROJECT_ROOT%\scripts" (
    mkdir "%PROJECT_ROOT%\scripts"
)

REM Create backup directory if it doesn't exist
if not exist "%SDK_BACKUP_DIR%" (
    mkdir "%SDK_BACKUP_DIR%"
)

REM Check if Flutter SDK directory exists
if not exist "%FLUTTER_SDK_DIR%" (
    echo Error: Flutter SDK directory not found at %FLUTTER_SDK_DIR%
    echo Please run this script from project root directory
    exit /b 1
)

REM Check if iOS SDK directory exists
if not exist "%IOS_SDK_DIR%" (
    echo Error: iOS SDK directory not found at %IOS_SDK_DIR%
    echo Please run this script from project root directory
    exit /b 1
)

REM Check if Android SDK directory exists
if not exist "%ANDROID_SDK_DIR%" (
    echo Error: Android SDK directory not found at %ANDROID_SDK_DIR%
    echo Please run this script from project root directory
    exit /b 1
)

REM Backup Flutter SDK
echo Backing up Flutter SDK to %SDK_BACKUP_DIR%...
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "DATE=%%c%%a%%b"
for /f "tokens=1-3 delims=:." %%a in ("%time%") do set "TIME=%%a%%b%%c"
set "TIMESTAMP=%DATE%_%TIME%"
set "BACKUP_NAME=llama_mobile_vd-flutter-SDK_%TIMESTAMP%"

REM Create backup directory
set "BACKUP_DIR=%SDK_BACKUP_DIR%\%BACKUP_NAME%"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM Copy Flutter SDK files to backup
xcopy "%FLUTTER_SDK_DIR%\*" "%BACKUP_DIR%\" /E /I /H /Y >nul

REM Change to Flutter SDK directory
pushd "%FLUTTER_SDK_DIR%"

REM Clean specific directories
echo Cleaning specific directories...

REM Clean iOS xcframework
if exist "ios\llama_mobile_vd.xcframework" (
    echo Cleaning iOS xcframework...
    rmdir /s /q "ios\llama_mobile_vd.xcframework"
)

REM Clean Android jniLibs
if exist "android\src\main\jniLibs" (
    echo Cleaning Android jniLibs...
    rmdir /s /q "android\src\main\jniLibs"
)

REM Create necessary directories
if not exist "ios\Classes" mkdir "ios\Classes"
if not exist "android\src\main\java\com\llamamobile\vd" mkdir "android\src\main\java\com\llamamobile\vd"
if not exist "android\src\main\kotlin\com\llamamobile\vd" mkdir "android\src\main\kotlin\com\llamamobile\vd"
if not exist "android\src\main\cpp\include" mkdir "android\src\main\cpp\include"
if not exist "android\src\main\jniLibs" mkdir "android\src\main\jniLibs"

REM Copy iOS xcframework
echo Copying iOS xcframework...
set "IOS_XCFRAMEWORK_SRC=%IOS_SDK_DIR%\llama_mobile_vd.xcframework"
set "IOS_XCFRAMEWORK_DST=%FLUTTER_SDK_DIR%\ios\llama_mobile_vd.xcframework"

if exist "%IOS_XCFRAMEWORK_SRC%" (
    xcopy "%IOS_XCFRAMEWORK_SRC%" "%IOS_XCFRAMEWORK_DST%\" /E /I /H /Y >nul
) else (
    echo Warning: iOS xcframework not found at %IOS_XCFRAMEWORK_SRC%
)

REM Copy Swift wrapper files from iOS SDK
echo Copying Swift wrapper files from iOS SDK...
set "SWIFT_SRC_FILE=%IOS_SDK_DIR%\Sources\LlamaMobileVD\LlamaMobileVD.swift"
set "SWIFT_DST_DIR=%FLUTTER_SDK_DIR%\ios\Classes"

if exist "%SWIFT_SRC_FILE%" (
    copy /y "%SWIFT_SRC_FILE%" "%SWIFT_DST_DIR%\" >nul
) else (
    echo Warning: Swift wrapper file not found at %SWIFT_SRC_FILE%
)

REM Copy Kotlin files from Android SDK (skip Java files to avoid conflicts)
echo Copying Kotlin files from Android SDK...
set "KOTLIN_SRC_FILE=%ANDROID_SDK_DIR%\src\main\kotlin\com\llamamobile\vd\LlamaMobileVDKt.kt"
set "KOTLIN_DST_DIR=%FLUTTER_SDK_DIR%\android\src\main\kotlin\com\llamamobile\vd"

if exist "%KOTLIN_SRC_FILE%" (
    copy /y "%KOTLIN_SRC_FILE%" "%KOTLIN_DST_DIR%\" >nul
) else (
    echo Warning: Kotlin file not found at %KOTLIN_SRC_FILE%
)

REM Copy JNI layer from Android SDK
echo Copying JNI layer from Android SDK...
set "JNI_CPP_SRC_DIR=%ANDROID_SDK_DIR%\src\main\cpp"
set "JNI_CPP_DST_DIR=%FLUTTER_SDK_DIR%\android\src\main\cpp"

if exist "%JNI_CPP_SRC_DIR%" (
    REM Copy specific JNI files
    copy /y "%JNI_CPP_SRC_DIR%\CMakeLists.txt" "%JNI_CPP_DST_DIR%\" >nul
    copy /y "%JNI_CPP_SRC_DIR%\llama_mobile_vd_jni.cpp" "%JNI_CPP_DST_DIR%\" >nul
    REM Copy include directory
    if exist "%JNI_CPP_SRC_DIR%\include" (
        xcopy "%JNI_CPP_SRC_DIR%\include" "%JNI_CPP_DST_DIR%\include\" /E /I /H /Y >nul
    )
) else (
    echo Warning: JNI CPP directory not found at %JNI_CPP_SRC_DIR%
)

REM Copy JNI libraries from Android SDK
echo Copying JNI libraries from Android SDK...
set "JNI_LIBS_SRC_DIR=%ANDROID_SDK_DIR%\src\main\jniLibs"
set "JNI_LIBS_DST_DIR=%FLUTTER_SDK_DIR%\android\src\main\jniLibs"

if exist "%JNI_LIBS_SRC_DIR%" (
    REM Copy specific architectures
    if exist "%JNI_LIBS_SRC_DIR%\arm64-v8a" (
        xcopy "%JNI_LIBS_SRC_DIR%\arm64-v8a" "%JNI_LIBS_DST_DIR%\arm64-v8a\" /E /I /H /Y >nul
    )
    if exist "%JNI_LIBS_SRC_DIR%\x86_64" (
        xcopy "%JNI_LIBS_SRC_DIR%\x86_64" "%JNI_LIBS_DST_DIR%\x86_64\" /E /I /H /Y >nul
    )
) else (
    echo Warning: JNI libraries directory not found at %JNI_LIBS_SRC_DIR%
)

REM Clean previous builds
echo Cleaning previous builds...
if exist "build" (
    rmdir /s /q build
)

REM Run Flutter pub get
echo Running flutter pub get...
flutter pub get

if %errorlevel% neq 0 (
    echo Error: flutter pub get failed
    popd
    exit /b 1
)

popd

echo Flutter SDK build completed successfully!
echo You can now use the Flutter SDK in your Flutter projects.
echo To use it, add the following to your pubspec.yaml:
echo.
echo dependencies:
echo   llama_mobile_vd_flutter_sdk:
echo     path: path/to/llama_mobile_vd-flutter-SDK
echo.
echo To run integration tests:
echo   flutter test integration_test
echo.
echo Backup created at: %BACKUP_DIR%

exit /b 0
