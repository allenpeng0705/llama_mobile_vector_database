@echo off
setlocal EnableDelayedExpansion

REM Desktop build script for QuiverDB wrapper corelib
REM Enhanced for cross-platform compatibility and user configurability

REM Set the working directory to the project root
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "PROJECT_ROOT=%SCRIPT_DIR%\.."
set "WRAPPER_DIR=%PROJECT_ROOT%\lib\wrapper"

REM ==========================
REM CENTRAL CONFIGURATION
REM Read settings from centralized config.env file if it exists
REM ==========================

REM Paths
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

REM Default configuration
set "DEFAULT_GENERATOR=Visual Studio"
for /f "usebackq tokens=*" %%a in (`get_config_value core BUILD_TYPE "Release"`) do set "DEFAULT_BUILD_TYPE=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value core BUILD_DIR "build-lib"`) do set "DEFAULT_BUILD_DIR=%PROJECT_ROOT%\%%a"
set "DEFAULT_SKIP_TESTS=false"
for /f "usebackq tokens=*" %%a in (`get_config_value core VERBOSE "false"`) do set "DEFAULT_VERBOSE=%%a"
for /f "usebackq tokens=*" %%a in (`get_config_value core NUM_CORES "0"`) do set "DEFAULT_NUM_CORES=%%a"
set "DEFAULT_CLEAN=false"

REM Update config file with defaults
update_config_value core BUILD_TYPE "%DEFAULT_BUILD_TYPE%"
update_config_value core BUILD_DIR "%DEFAULT_BUILD_DIR:~-%DEFAULT_BUILD_DIR:~-1%")
update_config_value core VERBOSE "%DEFAULT_VERBOSE%"
update_config_value core NUM_CORES "%DEFAULT_NUM_CORES%"

REM Configuration variables
set "GENERATOR=%DEFAULT_GENERATOR%"
set "BUILD_TYPE=%DEFAULT_BUILD_TYPE%"
set "BUILD_DIR=%DEFAULT_BUILD_DIR%"
set "SKIP_TESTS=%DEFAULT_SKIP_TESTS%"
set "VERBOSE=%DEFAULT_VERBOSE%"
set "NUM_CORES=%DEFAULT_NUM_CORES%"
set "CLEAN=%DEFAULT_CLEAN%"

REM Function to display usage information
usage() {
    echo Usage: %~nx0 [OPTIONS]
    echo.
    echo Build the QuiverDB wrapper core library on Windows
    echo.
    echo Options:
    echo   -g, --generator ^<generator^>  CMake generator to use (default: %DEFAULT_GENERATOR%)
    echo   -t, --type ^<build_type^>      Build type: Debug, Release, RelWithDebInfo (default: %DEFAULT_BUILD_TYPE%)
    echo   -d, --dir ^<build_dir^>        Build directory (default: %DEFAULT_BUILD_DIR%)
    echo   -j, --jobs ^<num^>             Number of parallel jobs (default: auto-detect)
    echo   -s, --skip-tests             Skip running tests after build
    echo   -c, --clean                  Clean existing build directories before building
    echo   -v, --verbose                Enable verbose output
    echo   -h, --help                   Display this help message
    echo.
    echo Examples:
    echo   %~nx0                          Build with default settings
    echo   %~nx0 --generator "Visual Studio 17 2022" --type Debug
    echo   %~nx0 --dir build-debug -j 8 --skip-tests
    echo   %~nx0 --clean -v               Clean and build with verbose output
}

REM Parse command line arguments
:parse_args
if "%~1" equ "" goto :end_parse_args

if "%~1" equ "-g" or "%~1" equ "--generator" (
    set "GENERATOR=%~2"
    shift
    shift
    goto :parse_args
) else if "%~1" equ "-t" or "%~1" equ "--type" (
    set "BUILD_TYPE=%~2"
    shift
    shift
    goto :parse_args
) else if "%~1" equ "-d" or "%~1" equ "--dir" (
    set "BUILD_DIR=%~2"
    shift
    shift
    goto :parse_args
) else if "%~1" equ "-j" or "%~1" equ "--jobs" (
    set "NUM_CORES=%~2"
    shift
    shift
    goto :parse_args
) else if "%~1" equ "-s" or "%~1" equ "--skip-tests" (
    set "SKIP_TESTS=true"
    shift
    goto :parse_args
) else if "%~1" equ "-c" or "%~1" equ "--clean" (
    set "CLEAN=true"
    shift
    goto :parse_args
) else if "%~1" equ "-v" or "%~1" equ "--verbose" (
    set "VERBOSE=true"
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

REM Check if CMake is installed
where cmake >nul 2>nul
if errorlevel 1 (
    echo ■■■ CMake not found
    echo Please install CMake from https://cmake.org/download/
    exit /b 1
)

REM Get CMake version
for /f "tokens=3 delims= " %%a in ('cmake --version') do (
    set "CMAKE_VERSION=%%a"
    goto :cmake_version_end
)
:cmake_version_end

REM Get number of CPU cores for parallel build
if "%NUM_CORES%" equ "0" (
    for /f "tokens=2 delims==" %%a in ('wmic cpu get NumberOfLogicalProcessors /value') do (
        set "NUM_CORES=%%a"
    )
)
if "%NUM_CORES%" equ "" set "NUM_CORES=1"

REM Display build configuration
echo === QuiverDB Core Library Build Configuration ===
echo Operating System: Windows
echo Generator: %GENERATOR%
echo Build Type: %BUILD_TYPE%
echo Build Directory: %BUILD_DIR%
echo Parallel Jobs: %NUM_CORES%
echo Run Tests: %SKIP_TESTS%
echo Verbose: %VERBOSE%
echo CMake Version: %CMAKE_VERSION%
echo ================================================

REM Function to build library
:build_library
set "LIB_TYPE=%~1"
set "SHARED_OPTION=%~2"
set "LIB_BUILD_DIR=%BUILD_DIR%-%LIB_TYPE%"

if "!LIB_TYPE!" equ "static" set "LIB_TYPE_NAME=Static"
if "!LIB_TYPE!" equ "shared" set "LIB_TYPE_NAME=Shared"

echo.
echo === Building !LIB_TYPE_NAME! Library ===

REM Clean existing build directory if requested
if "%CLEAN%" equ "true" (
    if exist "%LIB_BUILD_DIR%" (
        echo Cleaning existing build directory: %LIB_BUILD_DIR%
        rmdir /s /q "%LIB_BUILD_DIR%"
    )
)

REM Create build directory
if not exist "%LIB_BUILD_DIR%" (
    echo Creating build directory: %LIB_BUILD_DIR%
    mkdir "%LIB_BUILD_DIR%"
)

REM Configure CMake
echo Configuring CMake for !LIB_TYPE! build...
set "CMAKE_CMD=cmake -B "%LIB_BUILD_DIR%" -G "%GENERATOR%" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DBUILD_SHARED_LIBS=%SHARED_OPTION% "%WRAPPER_DIR%"

if "%VERBOSE%" equ "true" (
    echo Executing: !CMAKE_CMD!
)

!CMAKE_CMD!
if errorlevel 1 (
    echo ■■■ CMake configuration failed for !LIB_TYPE! build
    exit /b 1
)

REM Build the library
echo Building !LIB_TYPE! library with %NUM_CORES% cores...
set "BUILD_CMD=cmake --build "%LIB_BUILD_DIR%" --config %BUILD_TYPE% -j %NUM_CORES%

if "%VERBOSE%" equ "true" (
    echo Executing: !BUILD_CMD!
)

!BUILD_CMD!
if errorlevel 1 (
    echo ■■■ Build failed for !LIB_TYPE! library
    exit /b 1
)

echo ✅ !LIB_TYPE_NAME! library build completed successfully!

REM Return to caller
goto :eof

REM Build both static and shared libraries
echo Building static library...
call :build_library static OFF

if errorlevel 1 (
    echo ■■■ Static library build failed
    exit /b 1
)

echo Building shared library...
call :build_library shared ON

if errorlevel 1 (
    echo ■■■ Shared library build failed
    exit /b 1
)

REM Run tests if requested
if "%SKIP_TESTS%" neq "true" (
    echo.
    echo === Running Tests ===
    set "TEST_BUILD_DIR=%BUILD_DIR%-static"
    
    if exist "%TEST_BUILD_DIR%" (
        cd "%TEST_BUILD_DIR%"
        
        set "CTEST_CMD=ctest -C %BUILD_TYPE%"
        if "%VERBOSE%" equ "true" (
            echo Executing: !CTEST_CMD!
        )
        
        !CTEST_CMD!
        if errorlevel 1 (
            echo ■■■ Some tests failed
            exit /b 1
        ) else (
            echo ✅ All tests passed!
        )
    else (
        echo ■■■ Test build directory not found: %TEST_BUILD_DIR%
        echo Skipping tests
    )
)

REM Print final build summary
echo.
echo === Final Build Summary ===
echo Static Library: %BUILD_DIR%-staticBUILD_TYPE%ibquiverdb_wrapper.lib
echo Shared Library: %BUILD_DIR%-sharedBUILD_TYPE%uiverdb_wrapper.dll
echo Build Type: %BUILD_TYPE%
echo Generator: %GENERATOR%
echo Build Directories:
echo   - Static: %BUILD_DIR%-static
echo   - Shared: %BUILD_DIR%-shared
echo.
echo ✅ Build completed successfully!

exit /b 0