# 🏰 fortress 🏰

A hardened Docker container for running AI coding agents ([OpenCode](https://opencode.ai), [Claude Code](https://claude.ai), and [Codex](https://developers.openai.com/codex)) in isolation.

## Security features

- Read-only root filesystem
- All Linux capabilities dropped (`--cap-drop ALL`)
- No privilege escalation (`--security-opt no-new-privileges`)
- Unprivileged user (`fortress`, UID 1000)
- Process limit (256) and memory limit (2GB)
- Pinned base image by SHA256 digest

## Quick start

```bash
# build with all agents
./src/build.sh

# build with only one agent
./src/build.sh --agent claude
./src/build.sh --agent opencode
./src/build.sh --agent codex

# build named profiles
./src/build.sh --agent opencode --profile ocprofile
./src/build.sh --agent claude --profile cprofile
```

The build script automatically adds the `fortress` command to your PATH.

## Usage

From any project directory, run the `fortress` wrapper:

```bash
# run with opencode (default)
fortress

# run with claude code
fortress claude

# run with codex
fortress codex

# run an agent from a named profile
fortress opencode ocprofile
fortress claude cprofile

# drop into an interactive shell inside the container
fortress cmd
fortress cmd cprofile
```

The command syntax is `fortress [agent] [profile]`. The agent defaults to `opencode`, and omitting the profile uses the default `fortress:latest` image.

This mounts the current directory into `/workspace` inside the container. A persistent Docker volume preserves the home directory across runs. Named profiles use separate images, container names, and home volumes, so multiple profiles can run concurrently without sharing their persistent home state.

## Running Fortress inside this repository

Avoid launching Fortress from inside the Fortress repository, or from a parent directory that exposes it, unless you understand and accept the risk. The workspace is mounted read-write, so an agent could modify the `src/fortress` executable that the host later invokes. A subsequent `fortress` command would then run the modified script directly on the host, outside the container sandbox.

## Protecting Git metadata in critical environments

For highly security-sensitive work, consider launching Fortress from a subdirectory of a Git repository rather than its root. Fortress mounts only the current directory, so the repository's top-level `.git` directory remains outside the container and cannot be modified by the agent. This also means the agent sees only that subdirectory and repository-wide Git commands will generally not work inside the container.

## Files

| File | Purpose |
|---|---|
| `src/Dockerfile` | Container image with pinned base image |
| `src/build.sh` | Build script with agent and profile selection; adds `fortress` to PATH |
| `src/fortress` | Runtime wrapper that launches the hardened container |
