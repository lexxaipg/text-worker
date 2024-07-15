#FROM python:3.11-slim
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base

RUN apt-get -y update
RUN apt-get -y install python3
RUN apt-get -y install pip
RUN apt-get -y install python-is-python3

WORKDIR /worker

COPY requirements-scribe.txt .

RUN pip install --break-system-packages --no-cache-dir -r requirements-scribe.txt

COPY .. .

EXPOSE 443

#CMD ["python", "-s", "bridge_scribe.py"]

#USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Aipg-omniworker-dotnet/AipgOmniworker/AipgOmniworker.csproj", "AipgOmniworker/"]
RUN dotnet restore "AipgOmniworker/AipgOmniworker.csproj"
COPY Aipg-omniworker-dotnet/ .
WORKDIR "/src/AipgOmniworker"
RUN dotnet build "AipgOmniworker.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "AipgOmniworker.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "AipgOmniworker.dll"]
