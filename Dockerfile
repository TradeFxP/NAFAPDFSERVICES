# ---------------------------------
# Runtime
# ---------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:10.0-preview AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

# Install wkhtmltopdf dependencies
RUN apt-get update && apt-get install -y \
    wget \
    fontconfig \
    libfreetype6 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libjpeg-turbo8 \
    xfonts-75dpi \
    xfonts-base \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get purge -y wkhtmltox || true
RUN rm -rf /var/lib/dpkg/info/wkhtmltox*

# Install wkhtmltopdf (static, stable build)
RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb \
    && dpkg -i wkhtmltox_0.12.6-1.focal_amd64.deb \
    || apt-get -f install -y \
    && rm wkhtmltox_0.12.6-1.focal_amd64.deb

RUN which wkhtmltopdf
RUN wkhtmltopdf --version

ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

# ---------------------------------
# Build
# ---------------------------------
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src

COPY NafaGoldTry.PdfService/ NafaGoldTry.PdfService/

RUN dotnet restore NafaGoldTry.PdfService/NafaGoldTry.PdfService.csproj

RUN dotnet publish NafaGoldTry.PdfService/NafaGoldTry.PdfService.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# ---------------------------------
# Final
# ---------------------------------
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "NafaGoldTry.PdfService.dll"]

