FROM ghcr.io/actions/actions-runner:latest

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip zip openjdk-17-jdk build-essential git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Bazel system-wide
RUN curl -LO "https://github.com/bazelbuild/bazel/releases/download/8.4.2/bazel-8.4.2-installer-linux-x86_64.sh" && \
    chmod +x bazel-8.4.2-installer-linux-x86_64.sh && \
    ./bazel-8.4.2-installer-linux-x86_64.sh --prefix=/usr/local && \
    rm bazel-8.4.2-installer-linux-x86_64.sh

# Install Docker using official convenience script
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Add runner user to docker group
RUN usermod -aG docker runner

# Switch back to runner
USER runner
WORKDIR /home/runner

# Verify Bazel
RUN /usr/local/bin/bazel version

# Verify Docker
RUN docker --version
