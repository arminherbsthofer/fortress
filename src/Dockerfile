FROM debian:bookworm-slim@sha256:74d56e3931e0d5a1dd51f8c8a2466d21de84a271cd3b5a733b803aa91abf4421

# toggle agent installation
ARG INSTALL_OPENCODE=true
ARG INSTALL_CLAUDE=true

# create unprivileged user
RUN useradd -m -u 1000 fortress

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

# switch to unprivileged user
USER fortress
ENV HOME=/home/fortress
ENV TERM=xterm-256color

WORKDIR /workspace

CMD ["opencode"]
