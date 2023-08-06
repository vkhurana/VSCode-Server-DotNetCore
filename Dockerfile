FROM lscr.io/linuxserver/code-server:latest

ARG LABEL_VERSION="2.1"

LABEL name="VSCode-Server-DotNet" \
    version=${LABEL_VERSION} \
    description="VSCode Server with .NET Core SDK Pre-Installed" \
    maintainer="Vivek Khurana <vkhurana@users.noreply.github.com>"

    # Enable .NET detection of running in a container
    # See: https://github.com/dotnet/dotnet-docker/blob/master/3.0/sdk/bionic/amd64/Dockerfile
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # No installer frontend interaction
    DEBIAN_FRONTEND=noninteractive \
    # Do not show first run text
    DOTNET_NOLOGO=true \
    # Unset ASPNETCORE_URLS from aspnet base image
    ASPNETCORE_URLS= \
    # Do not generate certificate
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false

# Prerequisites
# https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu#dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libgcc1 \
        libgcc-s1 \
        libgssapi-krb5-2 \
        libicu70 \
        liblttng-ust1 \
        libssl3 \
        libstdc++6 \
        libunwind8 \
        wget  \
        zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# TODO: What is preferred way to set the root and get in path?
ENV DOTNET_ROOT=/usr/share/dotnet
ENV DOTNET_CLI_HOME=/usr/share/dotnet

# Install .NET
# https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x ./dotnet-install.sh \
    && ./dotnet-install.sh --install-dir /usr/share/dotnet --version latest --channel LTS\
    && ./dotnet-install.sh --install-dir /usr/share/dotnet --version latest --channel STS\
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && dotnet --list-runtimes \
    && dotnet --list-sdks

# # Install Powershell
# RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" \
#     && dpkg -i packages-microsoft-prod.deb \
#     && rm packages-microsoft-prod.deb \
#     && apt-get update \
#     && apt-get install -y powershell

# Cleanup
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*