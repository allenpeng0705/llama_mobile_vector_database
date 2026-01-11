@echo off
setlocal EnableDelayedExpansion

REM Flutter SDK build script for Llama Mobile VD

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

REM Function to read value from config file
get_config_value() {
    set "section=%~1"
    set "key=%~2"
    set "default=%~3"
    set "value="
    
    if exist "%CONFIG_FILE%" (
        for /f "usebackq tokens=*" %%a in (`findstr /r /c:"\[%section%\]" /c:"^%key%=" "%CONFIG_FILE%"`) do (
            if "%%a" neq "" (
                if "!value!" equ "" (
                    if "%%a:~0,1" equ "[" (
                        set "in_section=true"
                    ) else if "!in_section!" equ "true" (
                        if "%%a" equ "[%section%]" (
                            set "in_section=true"
                        ) else if "%%a:~0,1" equ "[" (
                            set "in_section=false"
                        ) else if "!in_section!" equ "true" (
                            if "%%a" neq "" (
                                for /f "tokens=1* delims==" %%b in ("%%a") do (
                                    if "%%~b" equ "%key%" (
                                        set "value=%%~c"
                                        goto :get_config_value_end
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
    
    :get_config_value_end
    if "!value!" equ "" (
        set "value=%default%"
    )
    echo %value%
}

REM Function to update value in config file
update_config_value() {
    set "section=%~1"
    set "key=%~2"
    set "new_value=%~3"
    
    if not exist "%CONFIG_FILE%" (
        echo Config file not found: %CONFIG_FILE%
        exit /b
    )
    
    REM Create a temporary file
    set "TEMP_FILE=%CONFIG_FILE%.tmp"
    set "in_section=false"
    set "updated=false"
    
    for /f "usebackq tokens=*" %%a in ("%CONFIG_FILE%") do (
        if "%%a" neq "" (
            if "%%a:~0,1" equ "[" (
                if "!in_section!" equ "true" (
                    echo %%a>>"%TEMP_FILE%"
                    set "in_section=false"
                    set "updated=true"
                ) else (
                    if "%%a" equ "[%section%]" (
                        echo %%a>>"%TEMP_FILE%"
                        set "in_section=true"
                    ) else (
                        echo %%a>>"%TEMP_FILE%"
                    )
                )
            ) else if "!in_section!" equ "true" (
                for /f "tokens=1* delims==" %%b in ("%%a") do (
                    if "%%~b" equ "%key%" (
                        echo %key%=%new_value%>>"%TEMP_FILE%"
                        set "updated=true"
                    ) else (
                        echo %%a>>"%TEMP_FILE%"
                    )
                )
            ) else (
                echo %%a>>"%TEMP_FILE%"
            )
        ) else (
            echo.>>"%TEMP_FILE%"
        )
    )
    
    REM If the key wasn't found, add it at the end of the section
    if "!updated!" equ "false" (
        set "in_section=false"
        set "TEMP_FILE2=%TEMP_FILE%.tmp"
        for /f "usebackq tokens=*" %%a in ("%TEMP_FILE%") do (
            if "%%a" neq "" (
                if "%%a:~0,1" equ "[" (
                    if "!in_section!" equ "true" (
                        echo %key%=%new_value%>>"%TEMP_FILE2%"
                        echo %%a>>"%TEMP_FILE2%"
                        set "in_section=false"
                    ) else (
                        if "%%a" equ "[%section%]" (
                            echo %%a>>"%TEMP_FILE2%"
                            set "in_section=true"
                        ) else (
                            echo %%a>>"%TEMP_FILE2%"
                        )
                    )
                ) else (
                    echo %%a>>"%TEMP_FILE2%"
                )
            ) else (
                echo.>>"%TEMP_FILE2%"
            )
        )
        
        REM If still not found, add the section and key at the end
        if "!in_section!" equ "true" (
            echo %key%=%new_value%>>"%TEMP_FILE2%"
        ) else (
            echo.>>"%TEMP_FILE2%"
            echo [%section%]>>"%TEMP_FILE2%"
            echo %key%=%new_value%>>"%TEMP_FILE2%"
        )
        
        del "%TEMP_FILE%"
        ren "%TEMP_FILE2%" "%TEMP_FILE%"
    )
    
    REM Replace the original file with the temporary one
    del "%CONFIG_FILE%"
    ren "%TEMP_FILE%" "%CONFIG_FILE%"
}

REM Default settings
for /f "usebackq tokens=*" %%a in (`get_config_value flutter FORCE_REBUILD "false"`) do set "DEFAULT_FORCE_BUILD=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value core VERBOSE "false"`) do set "DEFAULT_VERBOSE=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value flutter CLEAN_BUILD "false"`) do set "DEFAULT_CLEAN=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value core BUILD_TYPE "Release"`) do set "DEFAULT_BUILD_TYPE=%%a"

REM Update config file with defaults
update_config_value flutter FORCE_REBUILD "%DEFAULT_FORCE_BUILD%"
update_config_value flutter CLEAN_BUILD "%DEFAULT_CLEAN%"

REM Configuration variables
set "FORCE_BUILD=%DEFAULT_FORCE_BUILD%"
set "VERBOSE=%DEFAULT_VERBOSE%"
set "CLEAN=%DEFAULT_CLEAN%"
set "BUILD_TYPE=%DEFAULT_BUILD_TYPE%"

REM Function to display help message
usage() {
    echo Usage: %~nx0 [OPTIONS]
    echo.
    echo Build the Flutter SDK for Llama Mobile VD
    echo.
    echo REQUIRED ENVIRONMENT VARIABLES:
    echo   ANDROID_HOME          Path to Android SDK installation
    echo   JAVA_HOME             Path to Java JDK installation (Java 11 recommended)
    echo.
    echo OPTIONAL ENVIRONMENT VARIABLES:
    echo   FLUTTER_PATH          Path to Flutter SDK (auto-detected)
    echo   ANDROID_NDK_PATH      Path to Android NDK installation (auto-detected)
    echo   CMAKE_PATH            Path to CMake executable
    echo   BUILD_TYPE            Build type: Debug, Release (default: %DEFAULT_BUILD_TYPE%)
    echo.
    echo OPTIONS:
    echo   --force               Force rebuild of all components
    echo   -v, --verbose         Enable verbose output
    echo   -c, --clean           Clean existing build directories before building
    echo   -h, --help            Display this help message
    echo.
    echo Examples:
    echo   %~nx0                          Build with default settings
    echo   %~nx0 --force --verbose        Force rebuild with verbose output
    echo   %~nx0 --clean                  Clean and rebuild
}

REM Parse command line arguments
:parse_args
if "%~1" equ "" goto :end_parse_args

if "%~1" equ "--force" (
    set "FORCE_BUILD=true"
    shift
    goto :parse_args
) else if "%~1" equ "-v" or "%~1" equ "--verbose" (
    set "VERBOSE=true"
    shift
    goto :parse_args
) else if "%~1" equ "-c" or "%~1" equ "--clean" (
    set "CLEAN=true"
    shift
    goto :parse_args
) else if "%~1" equ "-h" or "%~1" equ "--help" (
    usage
    exit /b 0
) else (
    echo Unknown option: %~1
    usage
    exit /b 1
)

:end_parse_args

REM Define directories
set "FLUTTER_SDK_DIR=%PROJECT_ROOT%\llama_mobile_vd-flutter-SDK"
set "ios_FRAMEWORK_DEST=%FLUTTER_SDK_DIR%\ios\LlamaMobileVD.framework"
set "ANDROID_JNI_DEST=%FLUTTER_SDK_DIR%\android\src\main\jniLibs"

REM Check for required dependencies
where flutter >nul 2>nul
if errorlevel 1 (
    echo ■■■ Flutter SDK not found
    echo Please install Flutter SDK from https://flutter.dev/docs/get-started/install
    exit /b 1
)

where cmake >nul 2>nul
if errorlevel 1 (
    echo ■■■ CMake not found
    echo Please install CMake from https://cmake.org/download/
    exit /b 1
)

REM Build Android libraries first
if exist "%SCRIPT_DIR%\build-android.bat" (
    echo Building Android libraries for Flutter SDK...
    call "%SCRIPT_DIR%\build-android.bat"
    if errorlevel 1 (
        echo ■■■ Failed to build Android libraries
        exit /b 1
    )
) else (
    echo ■■■ build-android.bat not found
    exit /b 1
)

REM iOS framework warning (iOS builds only work on macOS)
echo Warning: iOS framework for Flutter can only be built on macOS

REM Final steps
echo === Final Steps for Flutter SDK ===
echo Flutter SDK build completed with Android components

echo To complete Flutter SDK setup:
1. For Android: All required components are built
2. For iOS: Build the iOS framework on macOS using build-ios.sh
3. Run: flutter pub get in your Flutter project
4. Add the SDK to your pubspec.yaml

echo Flutter SDK directory: %FLUTTER_SDK_DIR%
exit /b 0