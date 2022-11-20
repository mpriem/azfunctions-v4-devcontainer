FROM mcr.microsoft.com/dotnet/sdk:6.0.401-bullseye-slim-amd64

ENV DEBIAN_FRONTEND=noninteractive

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v7.2.7/powershell-lts_7.2.7-1.deb_amd64.deb

ADD ${PS_PACKAGE_URL} /tmp/powershell.deb

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache

ENV FUNCTIONS_WORKER_RUNTIME=powershell
ENV FUNCTIONS_WORKER_RUNTIME_VERSION=7.2

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get -y install \
    git \
    openssh-client \
    iproute2 \
    procps \
    curl \
    apt-transport-https \
    gnupg2 \
    lsb-release \
    less \
    locales \
    ca-certificates \
    gss-ntlmssp \
    && apt-get dist-upgrade -y \
    && sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen && update-locale \
    && apt install -y /tmp/powershell.deb \
    && rm /tmp/powershell.deb \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && apt-get update \
    && apt-get install -y azure-cli azure-functions-core-tools-4 \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && pwsh \
        -NoLogo \
        -NoProfile \
        -Command " \
        Set-PSRepository PSGallery -InstallationPolicy Trusted; \
        Install-Module -Name Az -AllowClobber -Scope AllUsers -Confirm:\$False -Force" \
    && pwsh -NoLogo -NoProfile -Command "try { IAmSureThisCommandDoesNotExist } catch { exit 0 }" \
    && pwsh \
        -NoLogo \
        -NoProfile \
        -Command " \
        \$ErrorActionPreference = 'Stop' ; \
        \$ProgressPreference = 'SilentlyContinue' ; \
        while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) {  \
            Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
            Start-Sleep -Seconds 6 ; \
        }" \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*