FROM python:3.11-slim

WORKDIR /home/app
ARG APP_GID="${APP_RUNTIME_GID:-24060}"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,rw \
    apt update && \
    apt install --no-install-recommends -y \
    curl git wget openssh-client rsync jq git-lfs vim \
    build-essential python3-dev cmake libomp-dev whiptail && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${APP_GID} modelbridge && \
    useradd -u ${APP_GID} -g modelbridge -m modelbridge && \
    mkdir -p /opt/ai-model-bridge && \
    chown -R modelbridge:modelbridge /opt/ai-model-bridge && \
    chown -R modelbridge:modelbridge /home/app
USER modelbridge:modelbridge

ARG CACHEBUST=1
RUN git clone --depth=1 https://github.com/DavidCatalano/ai-model-bridge.git

WORKDIR /home/app/ai-model-bridge
RUN ./start_linux.sh --setup --verbose


ENTRYPOINT ["/home/app/ai-model-bridge/entrypoint.sh"]

###### ENTRYPOINT ["/bin/bash", "-c", "source /home/app/ai-model-bridge/entrypoint.sh \"$@\"", "--"]

# Set ENTRYPOINT to source the script for environment setup
#ENTRYPOINT ["/bin/bash", "-c", "source /home/app/ai-model-bridge/start_linux.sh \"$@\"", "--"]

# CMD for default behavior
CMD ["--setup"]





# CMD ["bash", "-c", "umask 0002; export HOME=/home/app/ai-model-bridge; ./start_linux.sh --interactive"]
