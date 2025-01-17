FROM python:3.11-slim

WORKDIR /home/app
ARG APP_GID="${APP_RUNTIME_GID:-24060}"

# NVIDIA only
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    echo "deb http://deb.debian.org/debian bookworm contrib" >> /etc/apt/sources.list && \
    apt update && \
    apt install --no-install-recommends -y cuda-toolkit-12-6 && \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,rw \
    apt update && \
    apt install --no-install-recommends -y \
    # Core utilities
    curl wget zip rsync jq vim git git-lfs openssh-client gnupg \
    # Development tools and compilers
    build-essential gcc g++ make cmake python3-dev libomp-dev \
    # Additional utilities
    whiptail && \
    rm -rf /var/lib/apt/lists/*

# ENV CMAKE_ARGS="-DGGML_USE_CPU_X86=ON -DGGML_USE_CPU_AARCH64=OFF"
# ENV LLAMA_CPP_BUILD=1

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
CMD ["--webui"]
