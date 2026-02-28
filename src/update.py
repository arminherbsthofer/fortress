#!/usr/bin/env python3
"""Fetch the latest versions and install-script hashes for OpenCode and Claude Code."""

import hashlib
import json
import sys
import urllib.request


def fetch(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "get_update_info"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read()


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def get_opencode_info() -> tuple[str, str]:
    release = json.loads(fetch("https://api.github.com/repos/anomalyco/opencode/releases/latest"))
    version = release["tag_name"].lstrip("v")
    script_hash = sha256(fetch("https://opencode.ai/install"))
    return version, script_hash


def get_claude_info() -> tuple[str, str]:
    version = fetch(
        "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest"
    ).decode().strip()
    script_hash = sha256(fetch("https://claude.ai/install.sh"))
    return version, script_hash


def main() -> None:
    errors = []

    print("Fetching latest versions and install-script hashes...\n")

    try:
        oc_ver, oc_hash = get_opencode_info()
        print("OpenCode:")
        print(f"  OPENCODE_VERSION      = {oc_ver}")
        print(f"  OPENCODE_SCRIPT_HASH  = {oc_hash}")
    except Exception as e:
        errors.append(f"OpenCode: {e}")
        print(f"OpenCode: failed to fetch ({e})")

    print()

    try:
        cc_ver, cc_hash = get_claude_info()
        print("Claude Code:")
        print(f"  CLAUDE_VERSION        = {cc_ver}")
        print(f"  CLAUDE_SCRIPT_HASH    = {cc_hash}")
    except Exception as e:
        errors.append(f"Claude Code: {e}")
        print(f"Claude Code: failed to fetch ({e})")

    if errors:
        print()
        sys.exit(1)


if __name__ == "__main__":
    main()
