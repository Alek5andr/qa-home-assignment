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

# Устанавливаем OpenSSL для создания сертификатов
RUN apt-get update && apt-get install -y openssl

# Генерируем HTTPS сертификат с правильными SAN (Subject Alternative Names)
RUN mkdir /https && \
    echo "[req]" > /https/openssl.cnf && \
    echo "distinguished_name=req" >> /https/openssl.cnf && \
    echo "[v3_req]" >> /https/openssl.cnf && \
    echo "subjectAltName=@alt_names" >> /https/openssl.cnf && \
    echo "[alt_names]" >> /https/openssl.cnf && \
    echo "DNS.1=localhost" >> /https/openssl.cnf && \
    echo "DNS.2=cardvalidation-api" >> /https/openssl.cnf && \
    echo "IP.1=127.0.0.1" >> /https/openssl.cnf && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /https/aspnetapp.key \
    -out /https/aspnetapp.crt \
    -config /https/openssl.cnf \
    -extensions v3_req \
    -subj "/C=US/ST=CA/L=San Francisco/O=Development/CN=cardvalidation-api" && \
    openssl pkcs12 -export \
    -out /https/aspnetapp.pfx \
    -inkey /https/aspnetapp.key \
    -in /https/aspnetapp.crt \
    -password pass:password

FROM build AS publish
RUN dotnet publish "CardValidation.Web.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=build /https/aspnetapp.pfx /https/aspnetapp.pfx
COPY --from=build /https/aspnetapp.crt /https/aspnetapp.crt

# Устанавливаем переменные окружения для HTTPS
ENV ASPNETCORE_Kestrel__Certificates__Default__Password=password
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=/https/aspnetapp.pfx

# Создаём startup скрипт для копирования сертификата в общий volume
RUN echo '#!/bin/bash\n\
echo "Копируем встроенный сертификат в общий volume..."\n\
# Копируем сертификат из встроенной директории в volume\n\
if [ -f "/https/aspnetapp.pfx" ]; then\n\
    echo "Найден встроенный сертификат, копируем в volume..."\n\
    cp /https/aspnetapp.pfx /shared-volume/aspnetapp.pfx\n\
    cp /https/aspnetapp.crt /shared-volume/aspnetapp.crt\n\
    echo "Сертификат скопирован в общий volume!"\n\
    ls -la /shared-volume/\n\
else\n\
    echo "ОШИБКА: Встроенный сертификат не найден!"\n\
fi\n\
echo "Запуск приложения..."\n\
exec dotnet CardValidation.Web.dll\n\
' > /app/start.sh && chmod +x /app/start.sh

ENTRYPOINT ["/app/start.sh"]