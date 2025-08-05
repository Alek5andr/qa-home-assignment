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

# Настройка окружения тестирования для Windows 10

## 🚀 Быстрый старт

Выберите один из трёх вариантов запуска:

### Вариант 1: PowerShell скрипт (Рекомендуется)
```powershell
# Запуск всех тестов
.\run-pipeline.ps1

# Запуск конкретной команды
.\run-pipeline.ps1 build
.\run-pipeline.ps1 test-unit
.\run-pipeline.ps1 view-report
```

### Вариант 2: Batch файл (CMD)
```cmd
:: Запуск всех тестов
run-pipeline.bat

:: Запуск конкретной команды
run-pipeline.bat build
run-pipeline.bat test-unit
run-pipeline.bat view-report
```

### Вариант 3: Make (требует установки)
```powershell
# Установка через Chocolatey
choco install make

# Использование
make test
make test-unit
make view-report
```

## 📋 Предварительные требования

### 1. Docker Desktop для Windows
**Обязательно!** Установите Docker Desktop:
- Скачайте с: https://www.docker.com/products/docker-desktop
- Убедитесь, что Docker и docker-compose работают:
  ```powershell
  docker --version
  docker-compose --version
  ```

### 2. PowerShell (рекомендуется)
Windows 10 имеет встроенный PowerShell, но рекомендуется PowerShell 7:
- Скачайте с: https://github.com/PowerShell/PowerShell/releases
- Или установите через winget:
  ```cmd
  winget install Microsoft.PowerShell
  ```

## 🛠 Установка Make для Windows (опционально)

Если хотите использовать Makefile, установите Make одним из способов:

### Способ 1: Chocolatey (рекомендуется)
```powershell
# Установка Chocolatey (если не установлен)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Установка Make
choco install make
```

### Способ 2: Scoop
```powershell
# Установка Scoop (если не установлен)
iwr -useb get.scoop.sh | iex

# Установка Make
scoop install make
```

### Способ 3: Git for Windows
Если у вас установлен Git for Windows, Make может быть уже доступен:
```powershell
# Проверьте наличие
where make
```

### Способ 4: Visual Studio Build Tools
Make входит в состав Visual Studio Build Tools или Visual Studio.

## 🔧 Настройка PowerShell

### Разрешение выполнения скриптов
```powershell
# Временно для текущей сессии
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# Или постоянно для текущего пользователя
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Проверка кодировки
Убедитесь, что PowerShell использует UTF-8:
```powershell
# Проверка текущей кодировки
[Console]::OutputEncoding

# Установка UTF-8 (если нужно)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

## 📂 Структура файлов

После настройки у вас должны быть файлы:
```
├── run-pipeline.ps1      # PowerShell скрипт (основной)
├── run-pipeline.bat      # Batch скрипт (альтернатива)
├── Makefile.windows      # Makefile для Windows
├── Dockerfile            # Основное приложение
├── Dockerfile.tests      # Контейнер тестов
├── docker-compose.yml    # Конфигурация Docker
└── coverlet.runsettings  # Настройки покрытия
```

## 🚀 Способы запуска

### PowerShell (рекомендуется)
```powershell
# Справка
.\run-pipeline.ps1 help

# Полный pipeline
.\run-pipeline.ps1 test

# Отдельные команды
.\run-pipeline.ps1 build
.\run-pipeline.ps1 test-unit
.\run-pipeline.ps1 test-integration
.\run-pipeline.ps1 coverage
.\run-pipeline.ps1 view-report
```

### CMD/Batch
```cmd
rem Справка
run-pipeline.bat help

rem Полный pipeline
run-pipeline.bat test

rem Отдельные команды
run-pipeline.bat build
run-pipeline.bat test-unit
run-pipeline.bat test-integration
run-pipeline.bat view-report
```

### Make (если установлен)
```powershell
# Переименуйте Makefile.windows в Makefile
mv Makefile.windows Makefile

# Использование
make help
make test
make test-unit
make view-report
```

## 📊 Просмотр результатов

После выполнения тестов:

1. **HTML отчёт**: Автоматически откроется http://localhost:8080
2. **Локальные файлы**:
   - Результаты тестов: `.\test-results\`
   - HTML отчёт: `.\coverage\html-report\index.html`

## 🚨 Устранение проблем

### Docker не запускается
```powershell
# Проверьте статус Docker Desktop
Get-Process "*docker*"

# Перезапустите Docker Desktop
Stop-Service *docker*
Start-Service *docker*
```

### PowerShell не выполняет скрипты
```powershell
# Проверьте политику выполнения
Get-ExecutionPolicy

# Разрешите выполнение скриптов
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Ошибки кодировки (кракозябры)
```powershell
# Установите UTF-8 в консоли
chcp 65001

# Или в PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

### Make не найден
```powershell
# Проверьте установку
where make

# Если не найден, используйте PowerShell скрипт вместо Make
.\run-pipeline.ps1 test
```

### Порт 8080 занят
```powershell
# Найдите процесс, использующий порт
netstat -ano | findstr :8080

# Остановите контейнеры
docker-compose --profile report-viewer down
```

## 💡 Полезные команды

### Управление Docker
```powershell
# Статус контейнеров
docker-compose ps

# Логи
docker-compose logs test-runner

# Очистка
docker-compose down --remove-orphans --volumes
docker system prune -f
```

### Отладка
```powershell
# Проверка файлов результатов
Get-ChildItem .\test-results\ -Recurse
Get-ChildItem .\coverage\ -Recurse

# Проверка Docker образов
docker images | Select-String cardvalidation
```

## ⚙️ Кастомизация

### Изменение портов
В `docker-compose.yml`:
```yaml
services:
  report-viewer:
    ports:
      - "8081:80"  # Изменить порт веб-сервера
```

### Настройка покрытия кода
В `coverlet.runsettings`:
```xml
<Exclude>[*.Tests]*,[*]*.Program</Exclude>
<Include>[CardValidation.Core]*</Include>
```

## 🤝 Рекомендации

1. **Используйте PowerShell скрипт** - он наиболее универсален
2. **Установите Docker Desktop** - обязательное требование
3. **Разрешите выполнение скриптов** в PowerShell
4. **Проверьте кодировку** если видите кракозябры
5. **Используйте Windows Terminal** для лучшего опыта

---

**Быстрая проверка готовности системы:**
```powershell
# Запустите эту команду для проверки всех компонентов
docker --version; docker-compose --version; pwsh --version
if ($?) { Write-Host "✓ Система готова к работе" -ForegroundColor Green } else { Write-Host "✗ Требуется дополнительная настройка" -ForegroundColor Red }
```