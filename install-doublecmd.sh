#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
settings_file="$repo_dir/conf.doublecmd/settings.json"
config_root=${XDG_CONFIG_HOME:-"$HOME/.config"}
default_config_dir="$config_root/doublecmd"
config_dir=${DOUBLECMD_CONFIG_DIR:-"$default_config_dir"}
main_config="$config_dir/doublecmd.xml"
shortcut_config="$config_dir/shortcuts.scf"
association_config="$config_dir/extassoc.xml"
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
if [[ -f $association_config ]]; then
  cp -a -- "$association_config" "$backup_dir/"
fi
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

python3 - "$main_config" "$shortcut_config" "$association_config" "$settings_file" "$config_dir" <<'PY'
import sys
import os
import json
import xml.etree.ElementTree as ET

main_path, shortcuts_path, associations_path, settings_path, config_dir = sys.argv[1:]
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

# Merge portable file associations, preserving unrelated local associations.
if os.path.exists(associations_path):
    association_tree = ET.parse(associations_path)
    association_root = association_tree.getroot()
else:
    association_root = ET.Element("doublecmd")
    dc_version = main_root.get("DCVersion")
    if dc_version:
        association_root.set("DCVersion", dc_version)
    association_tree = ET.ElementTree(association_root)

association_sets = association_root.find("ExtensionAssociation")
if association_sets is None:
    association_sets = ET.SubElement(association_root, "ExtensionAssociation")

for association in settings.get("file_associations", []):
    file_type = association_sets.find(f"FileType[Name='{association['name']}']")
    if file_type is None:
        file_type = ET.Element("FileType")
    elif file_type in list(association_sets):
        association_sets.remove(file_type)
    association_sets.insert(0, file_type)

    set_child(file_type, "Name", association["name"])
    set_child(file_type, "IconFile", association.get("icon", ""))
    set_child(file_type, "ExtensionList", "|".join(association["extensions"]))
    actions = file_type.find("Actions")
    if actions is None:
        actions = ET.SubElement(file_type, "Actions")
    for action_data in association.get("actions", []):
        action = actions.find(f"Action[Name='{action_data['name']}']")
        if action is None:
            action = ET.SubElement(actions, "Action")
        set_child(action, "Name", action_data["name"])
        set_child(action, "Command", action_data["command"])
        set_child(action, "Params", action_data.get("params", ""))

ET.indent(association_tree, space="  ")
write_xml(association_tree, associations_path)

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
