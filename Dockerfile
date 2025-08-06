# Dockerfile for the main application
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 7135

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project files
COPY ["CardValidation.Web/CardValidation.Web.csproj", "CardValidation.Web/"]
COPY ["CardValidation.Core/CardValidation.Core.csproj", "CardValidation.Core/"]

# Restore dependencies
RUN dotnet restore "CardValidation.Web/CardValidation.Web.csproj"

# Copy all source code
COPY . .

# Build the application
WORKDIR "/src/CardValidation.Web"
RUN dotnet build "CardValidation.Web.csproj" -c Release -o /app/build

# Install OpenSSL for certificate creation
RUN apt-get update && apt-get install -y openssl

# Generate HTTPS certificate with correct SAN (Subject Alternative Names)
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

# Set environment variables for HTTPS
ENV ASPNETCORE_Kestrel__Certificates__Default__Password=password
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=/https/aspnetapp.pfx

# Create a startup script to copy the certificate to the shared volume
RUN echo '#!/bin/bash\n\
echo "Copying embedded certificate to shared volume..."\n\
# Copying certificate from embedded directory to volume\n\
if [ -f "/https/aspnetapp.pfx" ]; then\n\
    echo "Embedded certificate found, copying to volume..."\n\
    cp /https/aspnetapp.pfx /shared-volume/aspnetapp.pfx\n\
    cp /https/aspnetapp.crt /shared-volume/aspnetapp.crt\n\
    echo "Certificate copied to shared volume!"\n\
    ls -la /shared-volume/\n\
else\n\
    echo "ERROR: Embedded certificate not found!"\n\
fi\n\
echo "Starting application..."\n\
exec dotnet CardValidation.Web.dll\n\
' > /app/start.sh && chmod +x /app/start.sh

ENTRYPOINT ["/app/start.sh"]