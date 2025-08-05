# Dockerfile для основного приложения
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 7135

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Копируем файлы проекта
COPY ["CardValidation.Web/CardValidation.Web.csproj", "CardValidation.Web/"]
COPY ["CardValidation.Core/CardValidation.Core.csproj", "CardValidation.Core/"]

# Восстанавливаем зависимости
RUN dotnet restore "CardValidation.Web/CardValidation.Web.csproj"

# Копируем весь исходный код
COPY . .

# Собираем приложение
WORKDIR "/src/CardValidation.Web"
RUN dotnet build "CardValidation.Web.csproj" -c Release -o /app/build

# Генерируем HTTPS сертификат для разработки
RUN mkdir /https
RUN dotnet dev-certs https -ep /https/aspnetapp.pfx -p password

FROM build AS publish
RUN dotnet publish "CardValidation.Web.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=build /https/aspnetapp.pfx /https/aspnetapp.pfx

# Устанавливаем переменные окружения для HTTPS
ENV ASPNETCORE_Kestrel__Certificates__Default__Password=password
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=/https/aspnetapp.pfx

ENTRYPOINT ["dotnet", "CardValidation.Web.dll"]