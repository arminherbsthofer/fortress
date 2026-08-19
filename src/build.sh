#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage: build.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --agent <opencode|claude|codex|all>  Agent(s) to install (default: all)"
    echo "  --profile <name>                     Named image profile (default: fortress:latest)"
    echo "  -h, --help                           Show this help"
    exit "${1:-0}"
}

do_build() {
    local agent="$1"
    local profile="$2"
    local build_args=()
    local image="fortress"

    if [[ -n "$profile" ]]; then
        image="fortress:$profile"
    fi

    # bake the host user's UID into the image so bind-mounted
    build_args+=(--build-arg "HOST_UID=$(id -u)")

    case "$agent" in
        opencode)
            build_args+=(--build-arg INSTALL_OPENCODE=true --build-arg INSTALL_CLAUDE=false --build-arg INSTALL_CODEX=false)
            ;;
        claude)
            build_args+=(--build-arg INSTALL_OPENCODE=false --build-arg INSTALL_CLAUDE=true --build-arg INSTALL_CODEX=false)
            ;;
        codex)
            build_args+=(--build-arg INSTALL_OPENCODE=false --build-arg INSTALL_CLAUDE=false --build-arg INSTALL_CODEX=true)
            ;;
        all)
            build_args+=(--build-arg INSTALL_OPENCODE=true --build-arg INSTALL_CLAUDE=true --build-arg INSTALL_CODEX=true)
            ;;
    esac

    echo "Building $image (agent: $agent)..."
    docker build -t "$image" "${build_args[@]}" "$SCRIPT_DIR"
}

# defaults
AGENT="all"
PROFILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent)
            if [[ $# -lt 2 ]]; then
                echo "Missing value for --agent" >&2
                usage 1
            fi
            AGENT="$2"
            shift 2
            ;;
        --profile)
            if [[ $# -lt 2 ]]; then
                echo "Missing value for --profile" >&2
                usage 1
            fi
            PROFILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage 1
            ;;
    esac
done

case "$AGENT" in
    opencode|claude|codex|all) ;;
    *)
        echo "Invalid agent: $AGENT (must be opencode, claude, codex, or all)"
        exit 1
        ;;
esac

if [[ -n "$PROFILE" ]]; then
    if [[ "$PROFILE" == "latest" ]] || [[ ! "$PROFILE" =~ ^[a-z][a-z0-9_-]{0,62}$ ]]; then
        echo "Invalid profile: $PROFILE (use 1-63 lowercase letters, numbers, underscores, or hyphens; start with a letter; 'latest' is reserved)" >&2
        exit 1
    fi
fi

do_build "$AGENT" "$PROFILE"

chmod +x "$SCRIPT_DIR/fortress"

# Add fortress to PATH if not already there
install_fortress() {
    if [[ ":$PATH:" == *":$SCRIPT_DIR:"* ]]; then
        echo "fortress is already on PATH"
        return
    fi

    local shell_rc=""
    if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == */zsh ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"
    fi

    echo "export PATH=\"$SCRIPT_DIR:\$PATH\"" >> "$shell_rc"
    echo "Added $SCRIPT_DIR to PATH in $shell_rc"
    echo "Restart your shell or run: source $shell_rc"
}

install_fortress
