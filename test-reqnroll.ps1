Write-Host "Очистка проекта..." -ForegroundColor Yellow
dotnet clean CardValidation.Tests

Write-Host "Сборка проекта..." -ForegroundColor Yellow
dotnet build CardValidation.Tests

Write-Host "Запуск тестов..." -ForegroundColor Green
dotnet test CardValidation.Tests --verbosity normal

Write-Host "Готово!" -ForegroundColor Green
