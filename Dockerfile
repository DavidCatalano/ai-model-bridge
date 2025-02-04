FROM nvidia/cuda:12.6.0-devel-ubuntu22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
WORKDIR /home/app
ARG APP_GID="${APP_RUNTIME_GID:-24060}"

# Install Python 3.11
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,rw \
    apt update && \
    apt install --no-install-recommends -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt update && \
    apt install --no-install-recommends -y \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    python3-pip \
    # Core utilities
    curl wget zip rsync jq vim git git-lfs openssh-client gnupg \
    # Development tools and compilers
    build-essential gcc g++ make cmake libomp-dev ninja-build \
    # Additional utilities
    whiptail && \
    # Set Python 3.11 as default
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --set python3 /usr/bin/python3.11 && \
    # Clean up
    rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Set CUDA and compiler environment variables
ENV PATH="/usr/local/cuda/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}" \
    CUDA_HOME="/usr/local/cuda" \
    # Force use of system gcc/g++ for CUDA compilation
    CC=/usr/bin/gcc \
    CXX=/usr/bin/g++ \
    CUDAHOSTCXX=/usr/bin/g++ \
    # Set default CUDA architecture, can be overridden by .env
    TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-8.9}"

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