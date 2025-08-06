# Home Assignment

You will be required to write unit tests and automated tests for a payment application to demonstrate your skills. 

# Application information 

It’s an small microservice that validates provided Credit Card data and returns either an error or type of credit card application. 

# API Requirements 

API that validates credit card data. 

Input parameters: Card owner, Credit Card number, issue date and CVC. 

Logic should verify that all fields are provided, card owner does not have credit card information, credit card is not expired, number is valid for specified credit card type, CVC is valid for specified credit card type. 

API should return credit card type in case of success: Master Card, Visa or American Express. 

API should return all validation errors in case of failure. 


# Technical Requirements 

 - Write unit tests that covers 80% of application 
 - Write integration tests (preferably using Reqnroll framework) 
 - As a bonus: 
    - Create a pipeline where unit tests and integration tests are running with help of Docker. 
    - Produce tests execution results. 

# Running the  application 

1. Fork the repository
2. Clone the repository on your local machine 
3. Compile and Run application Visual Studio 2022.

# Setting up a Windows 10 testing environment

## 🚀 Quick Start

### Batch file (CMD)
```cmd
:: Run all tests
run-pipeline.bat

:: Run a specific command
run-pipeline.bat build
run-pipeline.bat test-unit
run-pipeline.bat view-report
```

## 📋 Prerequisites

### 1. Docker Desktop for Windows
**Required!** Install Docker Desktop:
- Download from: https://www.docker.com/products/docker-desktop
- Make sure Docker and docker-compose are running:
```cmd
docker --version
docker-compose --version
```

## 📂 File structure

After setup, you should have the following files:
```
├── run-pipeline.bat # Batch script
├── Dockerfile # Main application
├── Dockerfile.tests # Test container
├── docker-compose.yml # Docker configuration
└── coverlet.runsettings # Coverage settings
```

## 🚀 Run methods

### CMD/Batch
```cmd
rem Help
run-pipeline.bat help

rem Full pipeline
run-pipeline.bat test

rem Individual commands
run-pipeline.bat build
run-pipeline.bat test-unit
run-pipeline.bat test-integration
run-pipeline.bat view-report
```

## 📊 View results

After running tests:

1. **HTML report**: Will open automatically http://localhost:8080
2. **Local files**:
- Test results: `.\test-results\`
- HTML report: `.\coverage\html-report\index.html`

## 💡 Useful commands

### Docker management
```cmd
# Container status
docker-compose ps

# Logs
docker-compose logs test-runner

# Cleanup
docker-compose down --remove-orphans --volumes
docker system prune -f
```

### Debugging
```cmd
# Checking Docker images
docker images | Select-String cardvalidation
```

## ⚙️ Customization

### Changing ports
In `docker-compose.yml`:
```yaml
services:
report-viewer:
ports:
- "8081:80" # Change web server port
```

### Setting code coverage
In `coverlet.runsettings`:
```xml
<Exclude>[*.Tests]*,[*]*.Program</Exclude>
<Include>[CardValidation.Core]*</Include>
```