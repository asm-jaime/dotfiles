#!/usr/bin/env bash
set -euo pipefail

ini_path=${1:-${WINCMD_INI:-}}

if [[ -z $ini_path || ! -f $ini_path ]]; then
  printf 'Usage: %s /path/to/wincmd.ini\n' "${0##*/}" >&2
  exit 1
fi

if pgrep -fi 'TOTALCMD(64)?\.EXE' >/dev/null 2>&1; then
  printf 'Close Total Commander before changing %s.\n' "$ini_path" >&2
  exit 1
fi

backup_root="$HOME/.dotfiles-backup"
mkdir -p -- "$backup_root"
backup_file=$(mktemp "$backup_root/wincmd-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX.ini")
cp -a -- "$ini_path" "$backup_file"

python3 - "$ini_path" <<'PY'
import os
import re
import sys

path = sys.argv[1]
with open(path, encoding="latin-1", newline="") as handle:
    text = handle.read()

newline = "\r\n" if "\r\n" in text else "\n"
lines = text.splitlines(keepends=True)
mappings = {
    "C+S+C": "cm_CopyFullNamesToClip",
    "C+S+P": "cm_CopySrcPathToClip",
}

section_start = None
section_end = len(lines)
for index, line in enumerate(lines):
    match = re.match(r"^\s*\[([^]]+)]", line)
    if not match:
        continue
    if section_start is not None:
        section_end = index
        break
    if match.group(1).casefold() == "shortcuts":
        section_start = index

entries = [f"{key}={value}{newline}" for key, value in mappings.items()]
if section_start is None:
    if text and not text.endswith(("\n", "\r")):
        lines.append(newline)
    if lines and lines[-1].strip():
        lines.append(newline)
    lines.extend([f"[Shortcuts]{newline}", *entries])
else:
    found = set()
    for index in range(section_start + 1, section_end):
        match = re.match(r"^\s*([^=;#]+?)\s*=", lines[index])
        if not match:
            continue
        key = match.group(1).strip().upper()
        if key in mappings:
            lines[index] = f"{key}={mappings[key]}{newline}"
            found.add(key)
    missing = [entry for entry in entries if entry.split("=", 1)[0] not in found]
    lines[section_end:section_end] = missing

temporary_path = f"{path}.dotfiles.tmp"
with open(temporary_path, "w", encoding="latin-1", newline="") as handle:
    handle.write("".join(lines))
os.replace(temporary_path, path)
PY

printf 'Total Commander shortcuts configured; previous file backed up at %s\n' \
  "$backup_file"
