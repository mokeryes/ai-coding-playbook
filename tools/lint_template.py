#!/usr/bin/env python
"""CI helper: validate the cookiecutter template's basic structure."""

import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
COOKIECUTTER_JSON = REPO / "cookiecutter.json"
TEMPLATE_DIR = REPO / "{{cookiecutter.project_slug}}"

REQUIRED_KEYS = {
    "project_name",
    "project_slug",
    "primary_language",
    "owner",
}


def fail(msg: str) -> None:
    sys.stderr.write(f"ERROR: {msg}\n")
    sys.exit(1)


def check_cookiecutter_json() -> None:
    if not COOKIECUTTER_JSON.exists():
        fail(f"missing {COOKIECUTTER_JSON}")
    try:
        data = json.loads(COOKIECUTTER_JSON.read_text())
    except json.JSONDecodeError as exc:
        fail(f"cookiecutter.json invalid JSON: {exc}")
    missing = REQUIRED_KEYS - set(data.keys())
    if missing:
        fail(f"cookiecutter.json missing keys: {sorted(missing)}")
    print(f"[lint] cookiecutter.json OK ({len(data)} keys)")


def check_template_dir() -> None:
    if not TEMPLATE_DIR.is_dir():
        fail(f"missing template dir: {TEMPLATE_DIR}")
    must_have = ["CLAUDE.md", "README.md", "docs/README.md"]
    for rel in must_have:
        if not (TEMPLATE_DIR / rel).exists():
            fail(f"template missing: {rel}")
    print(f"[lint] template dir OK ({len(list(TEMPLATE_DIR.rglob('*')))} entries)")


def check_hooks() -> None:
    hooks_dir = REPO / "hooks"
    for name in ("pre_gen_project.py", "post_gen_project.py"):
        if not (hooks_dir / name).exists():
            fail(f"missing hook: {name}")
    print("[lint] hooks OK")


def main() -> None:
    check_cookiecutter_json()
    check_template_dir()
    check_hooks()
    print("[lint] all checks passed")


if __name__ == "__main__":
    main()
