#FROM python:3.11-slim
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 AS base

# Aphrodite

ENV HOME=/app/aphrodite-engine

WORKDIR $HOME

# Upgrade OS Packages + Prepare Python Environment
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get install -y bzip2 g++ git make python3-pip tzdata \
    && rm -fr /var/lib/apt/lists/*

# Alias python3 to python
RUN ln -s /usr/bin/python3 /usr/bin/python

RUN python3 -m pip install --no-cache-dir --upgrade pip

RUN git clone https://github.com/PygmalionAI/aphrodite-engine.git /tmp/aphrodite-engine \
    && mv /tmp/aphrodite-engine/* . \
    && rm -fr /tmp/aphrodite-engine \
    && chmod +x docker/entrypoint.sh

# Export the CUDA_HOME variable correctly
ENV CUDA_HOME=/usr/local/cuda

ENV HF_HOME=/tmp
ENV NUMBA_CACHE_DIR=$HF_HOME/numba_cache
ENV TORCH_CUDA_ARCH_LIST="6.1 7.0 7.5 8.0 8.6 8.9 9.0+PTX"
RUN python3 -m pip install --no-cache-dir -e .

# Entrypoint exec form doesn't do variable substitution automatically ($HOME)
#ENTRYPOINT ["/app/aphrodite-engine/docker/entrypoint.sh"]

EXPOSE 7860

#USER 1000:0

VOLUME ["/tmp"]

# Worker

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

# Dotnet
RUN aspnetcore_version=8.0.7 \
    && curl -fSL --output aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/$aspnetcore_version/aspnetcore-runtime-$aspnetcore_version-linux-x64.tar.gz \
    && aspnetcore_sha512='c7479dc008fce77c2bfcaa1ac1c9fe6f64ef7e59609fff6707da14975aade73e3cb22b97f2b3922a2642fa8d843a3caf714ab3a2b357abeda486b9d0f8bebb18' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && tar -oxzf aspnetcore.tar.gz ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz
	
ENV ASPNET_VERSION=8.0.7

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
