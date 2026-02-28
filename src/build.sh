#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage: build.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --agent <opencode|claude|both>  Agent(s) to install (default: both)"
    echo "  -h, --help                      Show this help"
    exit 0
}

do_build() {
    local agent="$1"
    local build_args=()

    case "$agent" in
        opencode)
            build_args+=(--build-arg INSTALL_OPENCODE=true --build-arg INSTALL_CLAUDE=false)
            ;;
        claude)
            build_args+=(--build-arg INSTALL_OPENCODE=false --build-arg INSTALL_CLAUDE=true)
            ;;
        both)
            build_args+=(--build-arg INSTALL_OPENCODE=true --build-arg INSTALL_CLAUDE=true)
            ;;
    esac

    echo "Building fortress image (agent: $agent)..."
    docker build -t fortress "${build_args[@]}" "$SCRIPT_DIR"
}

# defaults
AGENT="both"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent)
            AGENT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

case "$AGENT" in
    opencode|claude|both) ;;
    *)
        echo "Invalid agent: $AGENT (must be opencode, claude, or both)"
        exit 1
        ;;
esac

do_build "$AGENT"

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
