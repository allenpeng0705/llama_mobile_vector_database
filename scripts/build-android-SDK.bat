@echo off
REM ============================================================================
REM VECTOR DATABASE ANDROID SDK BUILD SCRIPT (Windows)
REM Takes pre-built Android libraries from llama_mobile_vd-android and creates clean Android SDKs
REM Output:
REM - llama_mobile_vector_database/llama_mobile_vd-android-SDK/ (Kotlin SDK)
REM - llama_mobile_vector_database/llama_mobile_vd-android-java-SDK/ (Java SDK)
REM ============================================================================

setlocal enabledelayedexpansion

REM Function to log messages
:log_message
set "LEVEL=%~1"
set "MESSAGE=%~2"
for /f "tokens=1-3 delims=:." %%a in ("%time%") do (
    set "TIMESTAMP=%%a:%%b:%%c"
)
echo [%TIMESTAMP%] [%LEVEL%] %MESSAGE%
goto :eof

REM Directory paths
set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%.."
set "PREBUILT_DIR=%ROOT_DIR%\llama_mobile_vd-android"
set "KOTLIN_SDK_DIR=%ROOT_DIR%\llama_mobile_vd-android-SDK"
set "JAVA_SDK_DIR=%ROOT_DIR%\llama_mobile_vd-android-java-SDK"
set "SDK_BACKUP_DIR=%ROOT_DIR%\scripts\sdk_backup"

REM Create backup directory if it doesn't exist
if not exist "%SDK_BACKUP_DIR%" (
    mkdir "%SDK_BACKUP_DIR%"
)

REM Function to backup SDK
:backup_sdk
set "SDK_DIR=%~1"
for %%f in ("%SDK_DIR%") do set "SDK_NAME=%%~nxf"

REM Get timestamp
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set "DATE=%%c%%a%%b"
for /f "tokens=1-3 delims=:." %%a in ("%time%") do set "TIME=%%a%%b%%c"
set "TIMESTAMP=%DATE%_%TIME%"
set "BACKUP_NAME=%SDK_NAME%_%TIMESTAMP%"
set "BACKUP_PATH=%SDK_BACKUP_DIR%\%BACKUP_NAME%"

call :log_message "INFO" "Backing up %SDK_NAME% to %BACKUP_PATH%"

REM Create backup as directory copy
xcopy "%SDK_DIR%" "%BACKUP_PATH%\" /E /I /H /Y >nul

if %errorlevel% equ 0 (
    call :log_message "INFO" "Backup completed successfully: %BACKUP_PATH%"
) else (
    call :log_message "ERROR" "Failed to create backup"
)
goto :eof

REM Main script execution
call :log_message "INFO" "Starting Vector Database Android SDK build process..."

REM Backup SDKs if they exist
if exist "%KOTLIN_SDK_DIR%" (
    call :backup_sdk "%KOTLIN_SDK_DIR%"
)

if exist "%JAVA_SDK_DIR%" (
    call :backup_sdk "%JAVA_SDK_DIR%"
)

REM Check if pre-built libraries exist
if not exist "%PREBUILT_DIR%\libs\arm64-v8a" (
    call :log_message "ERROR" "Pre-built libraries not found at %PREBUILT_DIR%\libs\arm64-v8a"
    call :log_message "INFO" "Please ensure llama_mobile_vd-android\libs contains the arm64-v8a and x86_64 directories with pre-built libraries"
    exit /b 1
)

if not exist "%PREBUILT_DIR%\libs\x86_64" (
    call :log_message "ERROR" "Pre-built libraries not found at %PREBUILT_DIR%\libs\x86_64"
    call :log_message "INFO" "Please ensure llama_mobile_vd-android\libs contains the arm64-v8a and x86_64 directories with pre-built libraries"
    exit /b 1
)

call :log_message "INFO" "Found pre-built libraries at %PREBUILT_DIR%"

REM Clean jniLibs directories
call :log_message "INFO" "Cleaning jniLibs directories..."

for %%d in ("%KOTLIN_SDK_DIR%" "%JAVA_SDK_DIR%") do (
    if exist "%%d" (
        REM Clean only jniLibs directories
        for %%a in ("%%d\src\main\jniLibs\arm64-v8a" "%%d\src\main\jniLibs\x86_64") do (
            if exist "%%a" (
                del /q "%%a\*.a" 2>nul
                call :log_message "INFO" "Cleaned %%a"
            )
        )
    )
)

REM Ensure jniLibs directories exist
call :log_message "INFO" "Ensuring jniLibs directories exist..."

for %%d in ("%KOTLIN_SDK_DIR%" "%JAVA_SDK_DIR%") do (
    if exist "%%d" (
        if not exist "%%d\src\main\jniLibs\arm64-v8a" mkdir "%%d\src\main\jniLibs\arm64-v8a"
        if not exist "%%d\src\main\jniLibs\x86_64" mkdir "%%d\src\main\jniLibs\x86_64"
        if not exist "%%d\src\main\cpp\include" mkdir "%%d\src\main\cpp\include"
    )
)

REM Copy pre-built libraries
call :log_message "INFO" "Copying pre-built libraries..."

for %%A in ("arm64-v8a" "x86_64") do (
    set "SOURCE_LIB=%PREBUILT_DIR%\libs\%%A\libllama_mobile_vd.a"
    if not exist "!SOURCE_LIB!" (
        call :log_message "ERROR" "Library not found for ABI %%A at !SOURCE_LIB!"
        exit /b 1
    )
    
    REM Copy to Kotlin SDK
    if exist "%KOTLIN_SDK_DIR%" (
        copy /y "!SOURCE_LIB!" "%KOTLIN_SDK_DIR%\src\main\jniLibs\%%A\" >nul
        call :log_message "INFO" "Copied %%A library to Kotlin SDK at %KOTLIN_SDK_DIR%\src\main\jniLibs\%%A\"
    )
    
    REM Copy to Java SDK
    if exist "%JAVA_SDK_DIR%" (
        copy /y "!SOURCE_LIB!" "%JAVA_SDK_DIR%\src\main\jniLibs\%%A\" >nul
        call :log_message "INFO" "Copied %%A library to Java SDK at %JAVA_SDK_DIR%\src\main\jniLibs\%%A\"
    )
)

REM Copy header files
if exist "%PREBUILT_DIR%\include" (
    REM Process Kotlin SDK
    if exist "%KOTLIN_SDK_DIR%" (
        REM Copy header files
        copy /y "%PREBUILT_DIR%\include\*.h" "%KOTLIN_SDK_DIR%\src\main\cpp\include\" >nul
        call :log_message "INFO" "Copied header files to Kotlin SDK at %KOTLIN_SDK_DIR%\src\main\cpp\include\"
    )
    
    REM Process Java SDK
    if exist "%JAVA_SDK_DIR%" (
        REM Copy header files
        copy /y "%PREBUILT_DIR%\include\*.h" "%JAVA_SDK_DIR%\src\main\cpp\include\" >nul
        call :log_message "INFO" "Copied header files to Java SDK at %JAVA_SDK_DIR%\src\main\cpp\include\"
    )
) else (
    call :log_message "WARN" "Header files not found at %PREBUILT_DIR%\include"
)

REM Function to run tests and build AAR
:run_tests_and_build
set "SDK_DIR=%~1"
for %%f in ("%SDK_DIR%") do set "SDK_NAME=%%~nxf"

call :log_message "INFO" "Running tests and building AAR for %SDK_NAME%"

REM Change to SDK directory
pushd "%SDK_DIR%"

REM Run unit tests
call :log_message "INFO" "Running unit tests for %SDK_NAME%"
call gradlew.bat test

if %errorlevel% neq 0 (
    call :log_message "ERROR" "Unit tests failed for %SDK_NAME%"
    popd
    exit /b 1
)

REM Build both debug and release AARs
call :log_message "INFO" "Building debug and release AARs for %SDK_NAME%"
call gradlew.bat assembleDebug assembleRelease

if %errorlevel% neq 0 (
    call :log_message "ERROR" "AAR build failed for %SDK_NAME%"
    popd
    exit /b 1
)

REM Create output directory and copy AARs
set "OUTPUT_DIR=%SDK_DIR%\output"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Find and copy all built AARs
for /r "%SDK_DIR%\build\outputs\aar" %%f in (*.aar) do (
    copy "%%f" "%OUTPUT_DIR%\" >nul
    call :log_message "INFO" "AAR copied to %OUTPUT_DIR%\%%~nxf"
)

REM Return to root directory
popd

exit /b 0

REM Run tests and build AAR for both SDKs
if exist "%KOTLIN_SDK_DIR%" (
    call :run_tests_and_build "%KOTLIN_SDK_DIR%"
    if %errorlevel% neq 0 (
        call :log_message "ERROR" "Failed to build Kotlin SDK"
        exit /b 1
    )
)

if exist "%JAVA_SDK_DIR%" (
    call :run_tests_and_build "%JAVA_SDK_DIR%"
    if %errorlevel% neq 0 (
        call :log_message "ERROR" "Failed to build Java SDK"
        exit /b 1
    )
)

call :log_message "INFO" "Android SDK build completed successfully!"
call :log_message "INFO" "Kotlin SDK directory: %KOTLIN_SDK_DIR%"
call :log_message "INFO" "Java SDK directory: %JAVA_SDK_DIR%"

REM Exit with success
exit /b 0
