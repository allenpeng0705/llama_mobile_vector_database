@echo off
setlocal EnableDelayedExpansion

REM iOS build script for QuiverDB wrapper and Llama Mobile VD framework
REM This script is intended for use on macOS only, but provides guidance for Windows users

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

REM Check if running on Windows
for /f "usebackq tokens=*" %%a in (`ver`) do set "OS_VERSION=%%a"
if "%OS_VERSION:Windows=%" neq "%OS_VERSION%" (
    echo ■■■ iOS builds are only supported on macOS
    echo This script is provided for completeness but will not work on Windows
    echo Please use a macOS system to build iOS SDKs
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
for /f "usebackq tokens=*" %%a in (`get_config_value core BUILD_TYPE "Release"`) do set "DEFAULT_BUILD_TYPE=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value ios IOS_DEPLOYMENT_TARGET "14.0"`) do set "DEFAULT_DEPLOYMENT_TARGET=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value ios IOS_ARCHS "arm64 x86_64"`) do set "DEFAULT_ARCHITECTURES=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value ios simulator_only "false"`) do set "DEFAULT_SIMULATOR_ONLY=%%a"

REM Update config file with defaults
update_config_value ios IOS_DEPLOYMENT_TARGET "%DEFAULT_DEPLOYMENT_TARGET%"
update_config_value ios IOS_ARCHS "%DEFAULT_ARCHITECTURES%"
update_config_value ios simulator_only "%DEFAULT_SIMULATOR_ONLY%"

REM Display iOS build guidance
echo === iOS Build Guidance ===
echo iOS builds are only supported on macOS systems

echo To build iOS SDKs:
1. Use a macOS system with Xcode installed
2. Open Terminal and navigate to the project root
3. Run: bash scripts/build-ios.sh
4. Follow the on-screen instructions

echo Required dependencies on macOS:
- Xcode 13.0+
- Xcode Command Line Tools
- CMake 3.20+
- Homebrew (recommended for installing dependencies)

echo For more information, please refer to the project documentation
exit /b 0