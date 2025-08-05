@echo off
setlocal enabledelayedexpansion

REM Pipeline testing CardValidation for Windows (CMD)
REM Set UTF-8 encoding
chcp 65001 >nul 2>&1

set "command=%~1"
if "%command%"=="" set "command=test"

REM Check Docker installation
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed or unavailable
    echo Install Docker Desktop for Windows
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] docker-compose is not installed or unavailable
    echo Install Docker Desktop for Windows
    exit /b 1
)

if "%command%"=="help" goto :show_help
if "%command%"=="build" goto :build
if "%command%"=="test" goto :test_full
if "%command%"=="test-unit" goto :test_unit
if "%command%"=="test-integration" goto :test_integration
if "%command%"=="coverage" goto :coverage
if "%command%"=="report" goto :report
if "%command%"=="view-report" goto :view_report
if "%command%"=="clean" goto :clean
if "%command%"=="stop" goto :stop
if "%command%"=="logs" goto :logs
if "%command%"=="status" goto :status
if "%command%"=="results" goto :results

echo [ERROR] Unknown command: %command%
echo Use: run-pipeline.bat help
exit /b 1

:show_help
echo.
echo === CardValidation Testing Pipeline ===
echo.
echo Usage: run-pipeline.bat [command]
echo.
echo Available commands:
echo   help                - Show this help
echo   build              - Build Docker images
echo   test               - Run all tests (default)
echo   test-unit          - Unit tests only
echo   test-integration   - Integration tests only
echo   coverage           - Generate coverage report
echo   report             - Start web server for report
echo   view-report        - Open report in browser
echo   clean              - Clean results
echo   stop               - Stop containers
echo   logs               - Show test logs
echo   status             - Container status
echo   results            - Show test results
echo.
echo Examples:
echo   run-pipeline.bat                    # Run all tests
echo   run-pipeline.bat build              # Build images
echo   run-pipeline.bat test-unit          # Unit tests only
echo   run-pipeline.bat view-report        # Open report
echo.
goto :eof

:create_directories
echo [INFO] Creating result directories...
if not exist ".\test-results\unit-tests" mkdir ".\test-results\unit-tests"
if not exist ".\test-results\integration-tests" mkdir ".\test-results\integration-tests"
if not exist ".\coverage" mkdir ".\coverage"
if not exist ".\coverage\html-report" mkdir ".\coverage\html-report"
goto :eof

:clean
echo [INFO] Cleaning previous results...
docker-compose down --remove-orphans --volumes >nul 2>&1
docker-compose --profile report-viewer down >nul 2>&1
if exist ".\test-results" rmdir /s /q ".\test-results" >nul 2>&1
if exist ".\coverage" rmdir /s /q ".\coverage" >nul 2>&1
echo [OK] Cleanup completed
goto :eof

:build
echo [INFO] Building Docker images...
docker-compose build
if errorlevel 1 (
    echo [ERROR] Error building images
    exit /b 1
)
echo [OK] Build completed successfully
goto :eof

:test_unit
echo [INFO] Running unit tests...
call :create_directories
docker-compose run --rm test-runner bash -c "dotnet test CardValidation.Tests --configuration Release --filter 'CardValidationServiceTests' --logger 'trx;LogFileName=unit-tests.trx' --results-directory ./test-results/unit-tests --collect:'XPlat Code Coverage' --settings coverlet.runsettings"
echo [OK] Unit tests completed
goto :eof

:test_integration
echo [INFO] Running integration tests...
call :create_directories
echo [INFO] Starting API...
docker-compose up -d cardvalidation-api
timeout /t 10 /nobreak >nul
echo [INFO] Running integration tests...
docker-compose run --rm test-runner bash -c "dotnet test CardValidation.Tests --configuration Release --filter 'CardValidation.Tests.Features' --logger 'trx;LogFileName=integration-tests.trx' --results-directory ./test-results/integration-tests --collect:'XPlat Code Coverage' --settings coverlet.runsettings"
docker-compose down
echo [OK] Integration tests completed
goto :eof

:coverage
echo [INFO] Generating coverage report...
docker-compose run --rm test-runner bash -c "reportgenerator -reports:'./coverage/**/coverage.cobertura.xml' -targetdir:'./coverage/html-report' -reporttypes:Html -verbosity:Info"
echo [OK] Coverage report created
goto :eof

:test_full
echo === Running full testing pipeline ===
call :clean
call :build
echo [INFO] Running all tests...
docker-compose up --abort-on-container-exit
call :coverage
call :results
echo === Pipeline completed ===
goto :eof

:report
call :coverage
echo [INFO] Starting web server for report...
docker-compose --profile report-viewer up -d report-viewer
echo [OK] Report available at: http://localhost:8080
goto :eof

:view_report
call :report
timeout /t 2 /nobreak >nul
if exist ".\coverage\html-report\index.html" (
    echo [INFO] Opening report in browser...
    start http://localhost:8080
) else (
    echo [ERROR] HTML report not found. Run tests first.
)
goto :eof

:logs
echo === Test Logs ===
docker-compose logs test-runner
goto :eof

:status
echo === Container Status ===
docker-compose ps
goto :eof

:results
echo === Test Results ===

REM Check unit tests
if exist ".\test-results\unit-tests\*" (
    echo [OK] Unit tests executed
    dir /b ".\test-results\unit-tests\"
) else (
    echo [!] Unit tests not found
)

REM Check integration tests
if exist ".\test-results\integration-tests\*" (
    echo [OK] Integration tests executed
    dir /b ".\test-results\integration-tests\"
) else (
    echo [!] Integration tests not found
)

REM Check HTML report
if exist ".\coverage\html-report\index.html" (
    echo [OK] HTML coverage report created
    for /f %%i in ('cd') do echo Local path: %%i\coverage\html-report\index.html
) else (
    echo [!] HTML report not created
)

echo.
echo Commands to view results:
echo   run-pipeline.bat report      - Start web server
echo   run-pipeline.bat view-report - Open report
echo   run-pipeline.bat stop        - Stop server
goto :eof

:stop
echo [INFO] Stopping containers...
docker-compose down --remove-orphans
docker-compose --profile report-viewer down
echo [OK] Containers stopped
goto :eof