@echo off
setlocal EnableDelayedExpansion

REM Build script for LlamaMobileVD Capacitor Plugin on Windows

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

REM Read configuration from config.env
for /f "usebackq tokens=*" %%a in (`get_config_value core BUILD_TYPE "Release"`) do set "BUILD_TYPE=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value core VERBOSE "false"`) do set "VERBOSE=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value capacitor CAP_PLATFORMS "android ios"`) do set "CAP_PLATFORMS=%%a"

REM Update config file with defaults
update_config_value capacitor CAP_PLATFORMS "%CAP_PLATFORMS%"

REM Define directories
set "CAPACITOR_PLUGIN_DIR=%PROJECT_ROOT%\llama_mobile_vd-capacitor-plugin"
set "ios_FRAMEWORK_DEST=%CAPACITOR_PLUGIN_DIR%\ios\LlamaMobileVD.framework"
set "ANDROID_JNI_DEST=%CAPACITOR_PLUGIN_DIR%\android\src\main\jniLibs"
set "ANDROID_JAVA_SRC_DEST=%CAPACITOR_PLUGIN_DIR%\android\src\main\java\com\llamamobile\vd"

REM Check dependencies
where npm >nul 2>nul
if errorlevel 1 (
    echo ■■■ npm not found
    echo Please install Node.js from https://nodejs.org/
    exit /b 1
)

where cmake >nul 2>nul
if errorlevel 1 (
    echo ■■■ CMake not found
    echo Please install CMake from https://cmake.org/download/
    exit /b 1
)

REM Build Android components
echo === Building Android Components for Capacitor Plugin ===

if exist "%SCRIPT_DIR%\build-android.bat" (
    echo Building Android libraries...
    call "%SCRIPT_DIR%\build-android.bat"
    if errorlevel 1 (
        echo ■■■ Failed to build Android libraries
        exit /b 1
    )
) else (
    echo ■■■ build-android.bat not found
    exit /b 1
)

REM Copy Android files to Capacitor plugin
echo Copying Android files to Capacitor plugin...

set "ANDROID_SDK_DIR=%PROJECT_ROOT%\llama_mobile_vd-android-SDK"
set "ANDROID_JNI_SRC=%ANDROID_SDK_DIR%\jniLibs"
set "ANDROID_JAVA_SRC_SRC=%ANDROID_SDK_DIR%\src\main\java\com\llamamobile\vd"

REM Copy JNI libraries
if exist "%ANDROID_JNI_SRC%" (
    if exist "%ANDROID_JNI_DEST%" (
        echo Removing existing JNI libraries...
        rmdir /s /q "%ANDROID_JNI_DEST%"
    )
    
    echo Copying JNI libraries...
    xcopy /s /e /i "%ANDROID_JNI_SRC%" "%ANDROID_JNI_DEST%"
    if errorlevel 1 (
        echo ■■■ Failed to copy JNI libraries
        exit /b 1
    )
    
    echo ✅ JNI libraries copied successfully
) else (
    echo ■■■ Android JNI libraries not found
    exit /b 1
)

REM Copy Java source code
if exist "%ANDROID_JAVA_SRC_SRC%" (
    if exist "%ANDROID_JAVA_SRC_DEST%" (
        echo Removing existing Java source code...
        rmdir /s /q "%ANDROID_JAVA_SRC_DEST%"
    )
    
    echo Copying Java source code...
    xcopy /s /e /i "%ANDROID_JAVA_SRC_SRC%" "%ANDROID_JAVA_SRC_DEST%"
    if errorlevel 1 (
        echo ■■■ Failed to copy Java source code
        exit /b 1
    )
    
    echo ✅ Java source code copied successfully
) else (
    echo ■■■ Android Java source code not found
    exit /b 1
)

REM iOS framework warning (iOS builds only work on macOS)
echo Warning: iOS framework for Capacitor can only be built on macOS

REM Final steps
echo === Final Steps for Capacitor Plugin ===
echo Capacitor plugin build completed with Android components

echo To complete Capacitor plugin setup:
1. For Android: All required components are built
2. For iOS: Build the iOS framework on macOS using build-ios.sh
3. Run: npm install in your Capacitor project
4. Run: npx cap sync

echo Capacitor plugin directory: %CAPACITOR_PLUGIN_DIR%
exit /b 0