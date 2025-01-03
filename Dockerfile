FROM python:3.11-slim

# Set up working directory and build arguments
WORKDIR /home/app
ARG APP_GID="${APP_RUNTIME_GID:-24060}"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,rw \
    apt update && \
    apt install --no-install-recommends -y \
    curl git wget rsync jq git-lfs vim \
    build-essential python3-dev cmake libomp-dev && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${APP_GID} modelbridge && \
    useradd -u ${APP_GID} -g modelbridge -m modelbridge && \
    chown -R modelbridge:modelbridge /home/app

RUN git clone https://github.com/DavidCatalano/ai-model-bridge.git

WORKDIR /home/app/ai-model-bridge
RUN ./start_linux.sh --setup --verbose

CMD ["./start_linux.sh", "--interactive"]
