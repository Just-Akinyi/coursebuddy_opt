# Base container
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    chromium-browser \
    adb \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter in home directory (no root permissions needed)
RUN git clone https://github.com/flutter/flutter.git /home/vscode/flutter
RUN git config --global --add safe.directory /home/vscode/flutter

# Set PATH
ENV PATH="/home/vscode/flutter/bin:/home/vscode/flutter/bin/cache/dart-sdk/bin:$PATH"

# Enable Flutter web
RUN flutter channel stable && flutter upgrade && flutter config --enable-web

# Accept Android licenses (optional, will warn without Android SDK)
RUN yes | flutter doctor --android-licenses || true
