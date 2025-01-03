FROM ubuntu:20.04

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl unzip tar libcurl4 libunwind8 libssl1.0 bash \
    && rm -rf /var/lib/apt/lists/*

# Add Azure DevOps agent binaries
RUN curl -sL https://vstsagentpackage.azureedge.net/agent/3.220.5/vsts-agent-linux-x64-3.220.5.tar.gz | tar zx

WORKDIR /azp

COPY start.sh .
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]