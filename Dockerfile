FROM ghcr.io/actions/actions-runner:latest

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip zip openjdk-17-jdk build-essential git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Bazel system-wide
RUN curl -LO "https://github.com/bazelbuild/bazel/releases/download/8.5.0/bazel-8.5.0-installer-linux-x86_64.sh" && \
    chmod +x bazel-8.5.0-installer-linux-x86_64.sh && \
    ./bazel-8.5.0-installer-linux-x86_64.sh --prefix=/usr/local && \
    rm bazel-8.5.0-installer-linux-x86_64.sh

# Install Docker using official convenience script
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

# Install GitHub CLI (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Add runner user to docker group
RUN usermod -aG docker runner

# Switch back to runner
USER runner
WORKDIR /home/runner

# Verify Bazel
RUN /usr/local/bin/bazel version

# Verify Docker
RUN docker --version

# Verify GitHub CLI
RUN gh --version
