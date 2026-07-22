#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
settings_file="$repo_dir/conf.doublecmd/settings.json"
config_root=${XDG_CONFIG_HOME:-"$HOME/.config"}
default_config_dir="$config_root/doublecmd"
config_dir=${DOUBLECMD_CONFIG_DIR:-"$default_config_dir"}
main_config="$config_dir/doublecmd.xml"
shortcut_config="$config_dir/shortcuts.scf"
copy_script_source="$repo_dir/conf.doublecmd/scripts/copy-active-path.lua"
copy_script_target="$config_dir/scripts/copy-active-path.lua"
debug_lua_source="$repo_dir/conf.doublecmd/scripts/open-debug-vim.lua"
debug_lua_target="$config_dir/scripts/open-debug-vim.lua"
debug_shell_source="$repo_dir/conf.doublecmd/scripts/open-debug-vim.sh"
debug_shell_target="$config_dir/scripts/open-debug-vim.sh"

if [[ $config_dir == "$default_config_dir" ]] && pgrep -x doublecmd >/dev/null 2>&1; then
  printf 'Close Double Commander before changing its configuration.\n' >&2
  exit 1
fi

if [[ ! -f $main_config || ! -f $shortcut_config ]]; then
  printf 'Start Double Commander once so it creates %s, then rerun this script.\n' \
    "$config_dir" >&2
  exit 1
fi

backup_root="$HOME/.dotfiles-backup"
mkdir -p -- "$backup_root"
backup_dir=$(mktemp -d "$backup_root/doublecmd-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")
cp -a -- "$main_config" "$shortcut_config" "$backup_dir/"
if [[ -f $copy_script_target || -f $debug_lua_target || -f $debug_shell_target ]]; then
  mkdir -p -- "$backup_dir/scripts"
  for installed_script in "$copy_script_target" "$debug_lua_target" "$debug_shell_target"; do
    if [[ -f $installed_script ]]; then
      cp -a -- "$installed_script" "$backup_dir/scripts/"
    fi
  done
fi

mkdir -p -- "${copy_script_target%/*}"
install -m 0644 -- "$copy_script_source" "$copy_script_target"
install -m 0644 -- "$debug_lua_source" "$debug_lua_target"
install -m 0755 -- "$debug_shell_source" "$debug_shell_target"

python3 - "$main_config" "$shortcut_config" "$settings_file" "$config_dir" <<'PY'
import sys
import os
import json
import xml.etree.ElementTree as ET

main_path, shortcuts_path, settings_path, config_dir = sys.argv[1:]
with open(settings_path, encoding="utf-8") as settings_handle:
    settings = json.load(settings_handle)


def set_child(parent, name, value):
    child = parent.find(name)
    if child is None:
        child = ET.SubElement(parent, name)
    child.text = value


def ensure_path(root, path):
    node = root
    for name in path.split("/"):
        child = node.find(name)
        if child is None:
            child = ET.SubElement(node, name)
        node = child
    return node


def dc_value(value):
    if value is True:
        return "True"
    if value is False:
        return "False"
    return str(value)


def write_xml(tree, path):
    temporary_path = f"{path}.dotfiles.tmp"
    tree.write(temporary_path, encoding="UTF-8", xml_declaration=True)
    os.replace(temporary_path, path)


# Merge the portable preferences into Double Commander's main configuration.
main_tree = ET.parse(main_path)
main_root = main_tree.getroot()
for path, attributes in settings.get("attributes", {}).items():
    node = ensure_path(main_root, path)
    for name, value in attributes.items():
        node.set(name, dc_value(value))
for path, value in settings.get("values", {}).items():
    ensure_path(main_root, path).text = dc_value(value)
ET.indent(main_tree, space="  ")
write_xml(main_tree, main_path)

# Merge the portable hotkeys into the native shortcut file.
shortcut_tree = ET.parse(shortcuts_path)
shortcut_root = shortcut_tree.getroot()
hotkeys = shortcut_root.find("Hotkeys")
if hotkeys is None:
    hotkeys = ET.SubElement(shortcut_root, "Hotkeys")
main_form = hotkeys.find("Form[@Name='Main']")
if main_form is None:
    main_form = ET.SubElement(hotkeys, "Form", {"Name": "Main"})

for binding in settings.get("hotkeys", []):
    shortcut = binding["shortcut"]
    control = binding.get("control")
    for hotkey in list(main_form.findall("Hotkey")):
        same_control = hotkey.findtext("Control") == control
        replaces_shortcut = hotkey.findtext("Shortcut") == shortcut
        replaces_command = (binding.get("replace_command", False)
                            and hotkey.findtext("Command") == binding["command"])
        if same_control and (replaces_shortcut or replaces_command):
            main_form.remove(hotkey)
    hotkey = ET.SubElement(main_form, "Hotkey")
    set_child(hotkey, "Shortcut", shortcut)
    set_child(hotkey, "Command", binding["command"])
    for parameter in binding.get("params", []):
        param = ET.SubElement(hotkey, "Param")
        param.text = parameter.replace("${DOUBLECMD_CONFIG_DIR}", config_dir)
    if control is not None:
        set_child(hotkey, "Control", control)

ET.indent(shortcut_tree, space="  ")
write_xml(shortcut_tree, shortcuts_path)
PY

printf 'Double Commander configured; previous files backed up in %s\n' "$backup_dir"
