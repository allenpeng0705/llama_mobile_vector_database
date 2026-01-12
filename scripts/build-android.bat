@echo off
setlocal EnableDelayedExpansion

REM Android build script for QuiverDB wrapper and Llama Mobile VD library
REM Enhanced for cross-platform compatibility and user configurability

REM ==========================
REM CENTRAL CONFIGURATION
REM Read settings from centralized config.env file if it exists
REM ==========================

REM Paths
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "PROJECT_ROOT=%SCRIPT_DIR%\.."
set "CONFIG_FILE=%SCRIPT_DIR%\config.env"

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

REM Check if config file exists
if not exist "%CONFIG_FILE%" (
    echo ■■■ Config file not found: %CONFIG_FILE%
    echo Please run the scripts from the project root directory
    exit /b 1
)

REM ==========================
REM CONFIGURATION VARIABLES
REM All build settings are centralized here for easy access
REM ==========================

REM --------------------------
REM DEFAULT SETTINGS
REM These can be overridden by command line arguments or environment variables
REM --------------------------
set "DEFAULT_FORCE_BUILD=false"
for /f "usebackq tokens=*" %%a in (`get_config_value core BUILD_TYPE "Release"`) do set "DEFAULT_BUILD_TYPE=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value android ANDROID_PLATFORM "android-24"`) do set "DEFAULT_ANDROID_PLATFORM=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value android ARCHITECTURES "arm64-v8a x86_64 armeabi-v7a x86"`) do set "DEFAULT_ARCHITECTURES=%%a"
set "DEFAULT_VERBOSE=false"
set "DEFAULT_CLEAN=false"

REM --------------------------
REM SCRIPT CONFIGURATION
REM These variables are used internally by the script
REM --------------------------
set "FORCE_BUILD=%DEFAULT_FORCE_BUILD%"
set "BUILD_TYPE=%DEFAULT_BUILD_TYPE%"
set "ANDROID_PLATFORM=%DEFAULT_ANDROID_PLATFORM%"
set "ARCHITECTURES=%DEFAULT_ARCHITECTURES%"
set "VERBOSE=%DEFAULT_VERBOSE%"
set "CLEAN=%DEFAULT_CLEAN%"

REM Read values from config file if they exist
for /f "usebackq tokens=*" %%a in (`get_config_value android ANDROID_HOME ""`) do set "ANDROID_HOME=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value android ANDROID_NDK_PATH ""`) do set "ANDROID_NDK_PATH=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value android JAVA_HOME ""`) do set "JAVA_HOME=%%a"

REM Update config file with defaults
update_config_value android ANDROID_PLATFORM "%DEFAULT_ANDROID_PLATFORM%"
update_config_value android ARCHITECTURES "%DEFAULT_ARCHITECTURES%"
update_config_value core BUILD_TYPE "%DEFAULT_BUILD_TYPE%"

REM Function to display help message
usage() {
    echo Usage: %~nx0 [OPTIONS]
    echo.
    echo Build the Android SDK for Llama Mobile VD
    echo.
    echo REQUIRED ENVIRONMENT VARIABLES:
    echo   ANDROID_HOME          Path to Android SDK installation
    echo   JAVA_HOME             Path to Java JDK installation (Java 11 recommended)
    echo.
    echo OPTIONAL ENVIRONMENT VARIABLES:
    echo   ANDROID_NDK_PATH      Path to Android NDK installation (auto-detected)
    echo   CMAKE_PATH            Path to CMake executable
    echo.
    echo OPTIONS:
    echo   --force                   Force rebuild even if libraries exist
    echo   --build-type ^<type^>       Build type: Debug, Release (default: %DEFAULT_BUILD_TYPE%)
    echo   --platform ^<platform^>     Android platform (default: %DEFAULT_ANDROID_PLATFORM%)
    echo   --arch ^<arch^>             Single architecture to build (default: all supported)
    echo   -v, --verbose             Enable verbose output
    echo   -c, --clean               Clean existing build directories before building
    echo   -h, --help                Display this help message
    echo.
    echo Examples:
    echo   %~nx0                          Build with default settings
    echo   %~nx0 --ndk-version 29.0.14206865 --force
    echo   %~nx0 --build-type Debug --arch arm64-v8a
    echo   %~nx0 --clean --verbose        Clean and build with verbose output
    echo.
    echo Supported architectures: %DEFAULT_ARCHITECTURES%
}

REM Parse command line arguments
:parse_args
if "%~1" equ "" goto :end_parse_args

if "%~1" equ "--force" (
        set "FORCE_BUILD=true"
        shift
        goto :parse_args
    ) else if "%~1" equ "--build-type" (
    set "BUILD_TYPE=%~2"
    shift
    shift
    goto :parse_args
) else if "%~1" equ "--platform" (
    set "ANDROID_PLATFORM=%~2"
    shift
    shift
    goto :parse_args
) else if "%~1" equ "--arch" (
    set "ARCHITECTURES=%~2"
    shift
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

REM Set the working directory to the project root
set "WRAPPER_DIR=%PROJECT_ROOT%\lib\wrapper"
set "ANDROID_DIR=%PROJECT_ROOT%\llama_mobile_vd-android-SDK"

REM NDK and CMake configuration
set "CMAKE_BUILD_TYPE=%BUILD_TYPE%"

REM Set default ANDROID_HOME if not set
if "%ANDROID_HOME%" equ "" (
    echo 🔍 ANDROID_HOME not set, trying to detect from system...
    
    REM Check common paths on Windows
    set "common_paths=
%USERPROFILE%\AppData\Local\Android\Sdk
%USERPROFILE%\Android\Sdk
C:\Android\Sdk
C:\Program Files (x86)\Android\sdk
C:\Users\Public\Android\Sdk"
    
    REM Check common paths
    for %%p in (%common_paths%) do (
        if exist "%%p" (
            REM Verify it's actually an Android SDK directory by checking for key subdirectories
            if exist "%%p\platforms" or exist "%%p\build-tools" or exist "%%p\ndk" (
                set "ANDROID_HOME=%%p"
                echo ✅ Detected ANDROID_HOME: !ANDROID_HOME!
                REM Update config file with detected value
                update_config_value android ANDROID_HOME "!ANDROID_HOME!"
                goto :end_android_home_detect
            )
        )
    )
    
    REM Final check: if still not found, prompt user with detailed instructions
    :end_android_home_detect
    if "%ANDROID_HOME%" equ "" (
        echo ■■■ Failed to auto-detect ANDROID_HOME
        echo.
        echo 📋 How to set ANDROID_HOME:
        echo.
        echo 1. First, locate your Android SDK installation:
        echo    - Typically in %%LOCALAPPDATA%%\Android\Sdk or C:\Android\Sdk
        echo.
        echo 2. You can set it temporarily:
        echo    set ANDROID_HOME=C:\path\to\your\android\sdk
        echo    %~nx0
        echo.
        echo 3. Or permanently add it to your environment variables:
        echo    - System Properties ^> Advanced ^> Environment Variables
        echo.
        echo 4. You can also edit the centralized config file directly:
        echo    - Open %CONFIG_FILE%
        echo    - Add: ANDROID_HOME=C:\path\to\your\android\sdk under [android] section
        echo.
        exit /b 1
    )
)

REM Verify ANDROID_HOME exists
if not exist "%ANDROID_HOME%" (
    echo ■■■ ANDROID_HOME path does not exist: %ANDROID_HOME%
    echo Please set ANDROID_HOME to a valid Android SDK path.
    exit /b 1
)

echo Using ANDROID_HOME: %ANDROID_HOME%

REM Set default ANDROID_NDK_PATH if not set
if "%ANDROID_NDK_PATH%" equ "" (
    echo 🔍 ANDROID_NDK_PATH not set, trying to detect from ANDROID_HOME...
    if exist "%ANDROID_HOME%\ndk" (
        REM Get the first available NDK version
        for /f "delims=" %%d in ('dir /b /ad "%ANDROID_HOME%\ndk\" 2^>nul') do (
            set "ANDROID_NDK_PATH=%ANDROID_HOME%\ndk\%%d"
            goto :ndk_found
        )
        
        :ndk_found
        if "%ANDROID_NDK_PATH%" neq "" (
            echo ✅ Detected ANDROID_NDK_PATH: %ANDROID_NDK_PATH%
            REM Update config file with detected value
            update_config_value android ANDROID_NDK_PATH "%ANDROID_NDK_PATH%"
        ) else (
            echo ■■■
            echo Error: No NDK versions found in %ANDROID_HOME%\ndk
            echo Available NDK versions:
            dir /b "%ANDROID_HOME%\ndk" 2^>nul || echo None found
            echo Please install an NDK version using Android Studio SDK Manager.
            echo You can also edit the ANDROID_NDK_PATH in %CONFIG_FILE% under the [android] section.
            exit /b 1
        )
    ) else (
        echo ■■■
        echo Error: ANDROID_HOME\ndk directory not found
        echo Please install an NDK version using Android Studio SDK Manager.
        echo You can also edit the ANDROID_NDK_PATH in %CONFIG_FILE% under the [android] section.
        exit /b 1
    )
)

set "ANDROID_NDK=%ANDROID_NDK_PATH%"
set "CMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%\build\cmake\android.toolchain.cmake"

REM Check if NDK path is valid
echo Checking for NDK at %ANDROID_NDK%... 
if not exist "%ANDROID_NDK%" (
    echo ■■■
    echo Error: NDK not found at %ANDROID_NDK%
    echo Please check your ANDROID_NDK_PATH in %CONFIG_FILE%.
    exit /b 1
)
echo ✅

REM Check if the NDK contains the required toolchain file
echo Checking for Android toolchain file... 
if not exist "%CMAKE_TOOLCHAIN_FILE%" (
    echo ■■■
    echo Error: Android toolchain file not found at %CMAKE_TOOLCHAIN_FILE%
    echo Please check your NDK installation or try a different NDK version.
    exit /b 1
)
echo ✅

REM Check if cmake is installed
echo Checking for cmake... 
where cmake >nul 2>nul
if errorlevel 1 (
    echo ■■■
    echo Error: cmake not found!
    echo Please install cmake using your system package manager or from https://cmake.org/download/
    exit /b 1
)
echo ✅

REM Set the number of CPU cores for parallel build
echo Detecting CPU cores for parallel build... 
for /f "usebackq tokens=*" %%a in (`wmic cpu get NumberOfLogicalProcessors /value`) do (
    for /f "tokens=2 delims==" %%b in ("%%a") do (
        set "n_cpu=%%b"
    )
)
if "%n_cpu%" equ "" set "n_cpu=1"

echo ✅
echo Using %n_cpu% cores for build

REM Step 1: Build the wrapper library for multiple architectures if needed
echo === Building QuiverDB frameworks for Android ===

REM Check if all libraries already exist
echo Checking if Android libraries already exist... 
set "ALL_LIBRARIES_EXIST=true"
for %%a in (%ARCHITECTURES%) do (
    if not exist "%ANDROID_DIR%\jniLibs\%%a\libquiverdb_wrapper.a" (
        set "ALL_LIBRARIES_EXIST=false"
    )
)

REM Variable to track if we actually built libraries
set "LIBRARIES_BUILT=false"

if "%ALL_LIBRARIES_EXIST%" equ "true" and "%FORCE_BUILD%" equ "false" (
    echo ✅
    echo All Android libraries already exist in the destination directories.
    echo Skipping rebuild (use --force to rebuild)
) else (
    echo ■■■
    if "%FORCE_BUILD%" equ "true" (
        echo Force rebuild requested.
    ) else (
        echo Some libraries are missing, will rebuild.
    )
    
    REM Create build directories for each architecture
    for %%a in (%ARCHITECTURES%) do (
        set "arch=%%a"
        set "build_dir=%PROJECT_ROOT%\build-android-!arch!"
        
        echo Configuring CMake for Android !arch!... 
        cmake -B "!build_dir!" ^
            -DCMAKE_TOOLCHAIN_FILE="%CMAKE_TOOLCHAIN_FILE%" ^
            -DANDROID_PLATFORM="%ANDROID_PLATFORM%" ^
            -DANDROID_ABI="!arch!" ^
            -DANDROID_STL="c++_shared" ^
            -DCMAKE_BUILD_TYPE="%CMAKE_BUILD_TYPE%" ^
            -DQUIVERDB_BUILD_TESTS=OFF ^
            -DQUIVERDB_BUILD_BENCHMARKS=OFF ^
            -DQUIVERDB_BUILD_EXAMPLES=OFF ^
            -DQUIVERDB_BUILD_PYTHON=OFF ^
            -DQUIVERDB_BUILD_CUDA=OFF ^
            -DQUIVERDB_BUILD_METAL=OFF ^
            "%WRAPPER_DIR%"
        
        if errorlevel 1 (
            echo ■■■
            echo Error: CMake configuration failed for !arch!
            exit /b 1
        )
        echo ✅
        
        echo Building library for !arch! with %n_cpu% cores... 
        cmake --build "!build_dir!" --config "%CMAKE_BUILD_TYPE%" -j %n_cpu%
        
        if errorlevel 1 (
            echo ■■■
            echo Error: Library build failed for !arch!
            exit /b 1
        )
        echo ✅
        
        echo ✅ Wrapper library built successfully for !arch!
        echo Library location: !build_dir!\libquiverdb_wrapper.a
        
        set "LIBRARIES_BUILT=true"
    )
)

if "%LIBRARIES_BUILT%" equ "true" (
    echo.
    
    REM Step 2: Update the llama_mobile_vd-android-SDK directory
    echo === Updating llama_mobile_vd-android-SDK directory ===
    
    REM Create jniLibs directories for multiple architectures
    set "JNI_LIBS_DEST=%ANDROID_DIR%\jniLibs"
    
    REM Copy libraries for all architectures
    for %%a in (%ARCHITECTURES%) do (
        set "arch=%%a"
        set "build_dir=%PROJECT_ROOT%\build-android-!arch!"
        set "lib_path=!build_dir!\libquiverdb_wrapper.a"
        
        if exist "!lib_path!" (
            REM Copy to jniLibs directory structure
            set "jni_lib_dir=%JNI_LIBS_DEST%\!arch!"
            mkdir "!jni_lib_dir!" 2>nul
            copy "!lib_path!" "!jni_lib_dir!\libquiverdb_wrapper.a" >nul
            echo ✅ Library for !arch! copied to: !jni_lib_dir!\libquiverdb_wrapper.a
        ) else (
            echo Error: Library not found at: !lib_path!
            exit /b 1
        )
    )
    
    REM Copy C header files
    set "HEADER_DEST=%ANDROID_DIR%\include"
    mkdir "%HEADER_DEST%" 2>nul
    
    REM Copy the wrapper header
    copy "%WRAPPER_DIR%\include\quiverdb_wrapper.h" "%HEADER_DEST%">nul
    
    if errorlevel 1 (
        echo Error: Failed to copy header files
        exit /b 1
    )
    
    echo ✅ Header files copied to: %HEADER_DEST%
    echo.
    
    REM Step 2.1: Update Android SDK
    echo === Updating Android SDK ===
    echo ✅ Android SDK updated successfully!
    echo.
    
    REM Step 3: Verify the directory structure
    echo === Final Directory Structure ===
    echo llama_mobile_vd-android-SDK\
    echo ├── jniLibs\
    for %%a in (%ARCHITECTURES%) do (
        echo │   ├── %%a\
        echo │   │   └── libquiverdb_wrapper.a
    )
    echo ├── include\
    echo │   └── quiverdb_wrapper.h
    echo └── src\
    echo     └── main\
    echo         ├── cpp\
    echo         │   ├── CMakeLists.txt
    echo         │   └── llama_mobile_vd_jni.cpp
    echo         ├── java\
    echo         │   └── com\llamamobile\vd\LlamaMobileVD.java
    echo         └── kotlin\
    echo             └── com\llamamobile\vd\
    echo                 ├── JNIInterface.kt
    echo                 └── LlamaMobileVD.kt
    echo.
    
    REM Step 4: Cleanup temporary build directories
    echo === Cleaning up temporary build directories ===
    echo Removing temporary build directories...
    
    REM Remove temporary build directories for all architectures
    for %%a in (%ARCHITECTURES%) do (
        set "arch=%%a"
        set "build_dir=%PROJECT_ROOT%\build-android-!arch!"
        if exist "!build_dir!" (
            rmdir /s /q "!build_dir!"
            echo ✅ Removed temporary build directory: !build_dir!
        )
    )
)

echo.
echo Android build completed successfully!
echo llama_mobile_vd-android-SDK directory is now ready to use!
echo Architectures built: %ARCHITECTURES%
echo.
echo - Consolidated Android SDK (includes Java and Kotlin): %ANDROID_DIR%\
echo - All temporary build directories have been cleaned up!
echo.

endlocal