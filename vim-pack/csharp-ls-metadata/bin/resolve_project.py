#!/usr/bin/env python3
"""Find the C# project and solution that own a source file."""

import glob
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import xml.etree.ElementTree as ET


def walk_files(root: Path, suffixes: tuple[str, ...]):
    for directory, children, files in os.walk(root):
        children[:] = sorted(child for child in children
                             if child not in {".git", ".vs", "bin", "obj", "node_modules"})
        for filename in sorted(files):
            if filename.endswith(suffixes):
                yield Path(directory) / filename


def repository_root(path: Path) -> Path:
    result = subprocess.run(
        ["git", "-C", str(path.parent), "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True,
        check=False,
    )
    return Path(result.stdout.strip()).resolve() if result.returncode == 0 else path.parent


def project_in_parents(path: Path) -> Path | None:
    for directory in (path.parent, *path.parent.parents):
        projects = sorted(directory.glob("*.csproj"))
        if projects:
            matching = [item for item in projects if item.stem == directory.name]
            return (matching or projects)[0].resolve()
    return None


def linked_to_project(path: Path, project: Path) -> bool:
    try:
        root = ET.parse(project).getroot()
    except (ET.ParseError, OSError):
        return False
    for element in root.iter():
        if element.tag.rsplit("}", 1)[-1] != "Compile":
            continue
        for pattern in element.attrib.get("Include", "").split(";"):
            if not pattern or "$(" in pattern:
                continue
            pattern = pattern.replace("\\", os.sep)
            for candidate in glob.iglob(str(project.parent / pattern), recursive=True):
                if Path(candidate).resolve() == path:
                    return True
    return False


def linked_project(path: Path, roots: list[Path]) -> Path | None:
    for root in roots:
        if not root.is_dir():
            continue
        for project in walk_files(root, (".csproj",)):
            if linked_to_project(path, project):
                return project.resolve()
    return None


def solution_projects(solution: Path) -> set[Path]:
    if solution.suffix == ".sln":
        paths = re.findall(r'"([^"\r\n]+\.csproj)"', solution.read_text(errors="replace"), re.I)
    else:
        try:
            root = ET.parse(solution).getroot()
            paths = [element.attrib["Path"] for element in root.iter()
                     if element.tag.rsplit("}", 1)[-1] == "Project"
                     and "Path" in element.attrib]
        except (ET.ParseError, OSError):
            paths = []
    return {(solution.parent / item.replace("\\", os.sep)).resolve() for item in paths}


def matching_solution(project: Path, root: Path) -> Path | None:
    if not root.is_dir() or not project.is_relative_to(root):
        root = project.parent
    candidates = []
    for solution in walk_files(root, (".sln", ".slnx")):
        members = solution_projects(solution)
        if project in members:
            # Prefer a solution named after this project; then one with
            # more source projects for cross-project navigation.
            candidates.append((solution.stem == project.stem, len(members), str(solution), solution))
    return max(candidates)[-1] if candidates else None


def main() -> int:
    path = Path(sys.argv[1]).resolve()
    root = repository_root(path)
    extra_roots = [Path(item).resolve() for item in sys.argv[2:]]
    project = project_in_parents(path) or linked_project(path, extra_roots + [root])
    if project is None:
        print(json.dumps({"error": f"No C# project owns {path}"}))
        return 0
    project_root = repository_root(project)
    solution = matching_solution(project, project_root)
    marker_path = path if not path.is_relative_to(project.parent) else project
    print(json.dumps({
        "project": str(project),
        "solution": str(solution) if solution else "",
        "marker": marker_path.name,
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
