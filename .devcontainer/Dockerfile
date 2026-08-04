FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive \
    MISE_INSTALL_PATH=/usr/local/bin/mise \
    MISE_DATA_DIR=/usr/local/share/mise \
    PATH=/usr/local/share/mise/shims:/usr/local/bin:${PATH}

# Install basic tools
RUN apt-get update && apt-get install -y \
    bash-completion \
    ca-certificates \
    curl \
    dnsutils \
    git \
    jq && \
    rm -rf /var/lib/apt/lists/*

# Install Mise
RUN curl https://mise.run | sh

# Use Mise to install the other tools for this course from .mise.toml
COPY .mise.toml /tmp/mise/.mise.toml
RUN mkdir -p "${MISE_DATA_DIR}" && \
    cd /tmp/mise && \
    mise trust .mise.toml && \
    mise install && \
    rm -rf /tmp/mise

# Separately, install K3D. It's not in .mise.toml as it's only need for Codespaces. \
RUN mise install k3d@5.8.3

LABEL org.opencontainers.image.source https://github.com/LinkedInLearning/devops-foundations-core-principles-and-real-world-practices-for-modern-software-delivery-7773006