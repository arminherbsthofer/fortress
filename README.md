# 🏰 fortress 🏰

A security-hardened Docker container for running AI coding agents ([OpenCode](https://opencode.ai) and [Claude Code](https://claude.ai)) in isolation.

## Security features

- Read-only root filesystem
- All Linux capabilities dropped (`--cap-drop ALL`)
- No privilege escalation (`--security-opt no-new-privileges`)
- Unprivileged user (`fortress`, UID 1000)
- Process limit (256) and memory limit (2GB)
- Pinned base image by SHA256 digest
- Pinned agent versions with install script checksum verification

## Quick start

```bash
# build with both agents
./src/build.sh

# build with only one agent
./src/build.sh --agent claude
./src/build.sh --agent opencode
```

The build script automatically adds the `fortress` command to your PATH.

## Usage

From any project directory, run the `fortress` wrapper:

```bash
# run with opencode (default)
fortress

# run with claude code
fortress claude

# drop into an interactive shell inside the container
fortress cmd
```

This mounts the current directory into `/workspace` inside the container. A persistent Docker volume (`fortress_home`) preserves the home directory across runs.

## Updating agent versions

```bash
python3 src/update.py
```

This fetches the latest versions and install script hashes for both agents. Update the `ARG` values in `src/Dockerfile` with the printed output, then rebuild with `./src/build.sh`.

## Files

| File | Purpose |
|---|---|
| `src/Dockerfile` | Container image with pinned base image, versions, and script checksums |
| `src/build.sh` | Build script with agent selection; adds `fortress` to PATH |
| `src/fortress` | Runtime wrapper that launches the container with security hardening |
| `src/update.py` | Fetches latest agent versions and install script hashes |
