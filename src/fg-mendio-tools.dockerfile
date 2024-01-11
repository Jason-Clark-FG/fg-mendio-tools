ARG DOTNET_VERSION="6.0"

FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG DOTNET_VERSION

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

USER root

# Ref: https://stackoverflow.com/questions/73753672/a-fatal-error-occurred-the-folder-usr-share-dotnet-host-fxr-does-not-exist/73899341#73899341
RUN apt-get update; \
    apt-get --assume-yes dist-upgrade; \
    apt-get --assume-yes --no-install-recommends install ca-certificates curl apt-transport-https lsb-release gnupg; \
    apt-get --assume-yes remove dotnet* aspnetcore* netstandard*; \
    curl -fsSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -o packages-microsoft-prod.deb; \
    dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb; \
    printf 'Package: *\nPin: origin "packages.microsoft.com"\nPin-Priority: 1001\n' > /etc/apt/preferences.d/99-microsoft-dotnet.pref; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg && chmod go+r /etc/apt/keyrings/microsoft.gpg; \
    printf "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main\n" > /etc/apt/sources.list.d/azure-cli.list; \
    apt-get update; \
    apt-get --assume-yes --no-install-recommends install azure-cli dotnet-sdk-${DOTNET_VERSION} git jq nodejs nuget; \
    az extension add --name azure-devops; \
    curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/bin/yq && chmod +x /usr/bin/yq; \
    curl -fsSL https://downloads.mend.io/cli/linux_amd64/mend -o /usr/local/bin/mend && chmod +x /usr/local/bin/mend; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# RUN az version; \
#     dotnet --version; \
#     git --version; \
#     jq --version; \
#     mend version --non-interactive; \
#     node --version; \
#     yq --version

