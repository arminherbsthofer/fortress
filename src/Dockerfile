FROM debian:trixie-slim@sha256:3a39a0592364683e6bab97937b72cad5a8fa6dcbbee90edb3bb48c7f8e94f258

# toggle agent installation
ARG INSTALL_OPENCODE=true
ARG INSTALL_CLAUDE=true
ARG INSTALL_CODEX=true

# create unprivileged user with the host's UID
ARG HOST_UID=1000
RUN useradd -m -u "${HOST_UID}" fortress

# install only what you actually need
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        tar \
        gzip \
        unzip \
        git \
        ripgrep \
        vim \
        poppler-utils \
        python3 \
        python3-requests \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# install opencode as fortress, then move binary to a system path
USER fortress
RUN if [ "$INSTALL_OPENCODE" = "true" ]; then \
    curl -fsSL https://opencode.ai/install -o /tmp/install.sh && \
    bash /tmp/install.sh && \
    rm /tmp/install.sh; \
    fi

USER root
RUN if [ "$INSTALL_OPENCODE" = "true" ]; then \
    cp /home/fortress/.opencode/bin/* /usr/local/bin/ && \
    rm -rf /home/fortress/.opencode; \
    fi

# install claude code
USER fortress
RUN if [ "$INSTALL_CLAUDE" = "true" ]; then \
    curl -fsSL https://claude.ai/install.sh -o /tmp/install-claude.sh && \
    bash /tmp/install-claude.sh && \
    rm /tmp/install-claude.sh; \
    fi

USER root
RUN if [ "$INSTALL_CLAUDE" = "true" ]; then \
    cp /home/fortress/.local/bin/claude /usr/local/bin/ && \
    rm -rf /home/fortress/.local/bin/claude; \
    fi

# install codex
USER fortress
RUN if [ "$INSTALL_CODEX" = "true" ]; then \
    curl -fsSL https://chatgpt.com/codex/install.sh -o /tmp/install-codex.sh && \
    bash /tmp/install-codex.sh && \
    rm /tmp/install-codex.sh; \
    fi

USER root
RUN if [ "$INSTALL_CODEX" = "true" ]; then \
    cp /home/fortress/.codex/packages/standalone/current/bin/codex /usr/local/bin/ && \
    cp /home/fortress/.codex/packages/standalone/current/bin/codex-code-mode-host /usr/local/bin/ && \
    rm -rf /home/fortress/.codex /home/fortress/.local/bin/codex; \
    fi

# copy opencode config and skills
COPY --chown=fortress:fortress config/opencode.jsonc /home/fortress/.config/opencode/opencode.jsonc
COPY --chown=fortress:fortress skills/ /home/fortress/.config/opencode/skills/

# switch to unprivileged user
USER fortress
ENV HOME=/home/fortress
ENV TERM=xterm-256color

# disable opencode web requests
ENV OPENCODE_DISABLE_MODELS_FETCH=1
ENV OPENCODE_DISABLE_LSP_DOWNLOAD=1

WORKDIR /workspace

CMD ["opencode"]
