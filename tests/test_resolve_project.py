import importlib.util
from pathlib import Path
import tempfile
import unittest


RESOLVER = Path(__file__).resolve().parents[1] / "vim-pack/csharp-ls-metadata/bin/resolve_project.py"
SPEC = importlib.util.spec_from_file_location("resolve_project", RESOLVER)
resolve_project = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(resolve_project)


class ResolveProjectTests(unittest.TestCase):
    def test_nearest_project_and_matching_solution(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            project_dir = root / "service"
            project_dir.mkdir()
            project = project_dir / "Service.csproj"
            project.write_text('<Project Sdk="Microsoft.NET.Sdk" />')
            source = project_dir / "Nested" / "Program.cs"
            source.parent.mkdir()
            source.write_text("class Program {}")
            (root / "Other.sln").write_text('Project("x") = "Other", "other\\Other.csproj", "x"\n')
            solution = root / "Service.sln"
            solution.write_text('Project("x") = "Service", "service\\Service.csproj", "x"\n')

            self.assertEqual(resolve_project.project_in_parents(source), project)
            self.assertEqual(resolve_project.matching_solution(project, root), solution)

    def test_linked_file_outside_project(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            project_dir = root / "tests"
            source_dir = root / "shared"
            project_dir.mkdir()
            source_dir.mkdir()
            project = project_dir / "Tests.csproj"
            source = source_dir / "Linked.cs"
            source.write_text("class Linked {}")
            project.write_text(
                '<Project Sdk="Microsoft.NET.Sdk"><ItemGroup>'
                '<Compile Include="..\\shared\\Linked.cs" Link="Linked.cs" />'
                '</ItemGroup></Project>'
            )

            self.assertIsNone(resolve_project.project_in_parents(source))
            self.assertEqual(resolve_project.linked_project(source, [root]), project)


if __name__ == "__main__":
    unittest.main()
