# Установка ReportGenerator как dotnet tool (если еще не установлен)
dotnet tool install --global dotnet-reportgenerator-globaltool --version 5.2.4

# Запуск тестов с покрытием
dotnet test CardValidation.Tests --collect:"XPlat Code Coverage" --results-directory ./coverage

# Генерация HTML отчета
reportgenerator -reports:"./coverage/**/coverage.cobertura.xml" -targetdir:"./coverage/html-report" -reporttypes:Html

Write-Host "HTML отчет создан в: ./coverage/html-report/index.html" -ForegroundColor Green 