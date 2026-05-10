#!/usr/bin/env python
"""cookiecutter post-generation hook:

1. Re-render files that binaryornot mis-detected as binary
   (中文 Markdown 文件容易被误判,尤其是 CLAUDE.md / 短小但符号密集的文件)
2. Optionally drop .claude/ when include_skills=no
3. Optionally git init when git_init=yes
4. Print summary + next-steps
"""

import re
import shutil
import subprocess
from pathlib import Path

# Cookiecutter substitutes these placeholders at hook-render time,
# so at runtime CONTEXT holds the real values.
CONTEXT = {
    "cookiecutter": {
        "project_name": """{{ cookiecutter.project_name }}""",
        "project_slug": """{{ cookiecutter.project_slug }}""",
        "project_description": """{{ cookiecutter.project_description }}""",
        "primary_language": """{{ cookiecutter.primary_language }}""",
        "tech_stack_summary": """{{ cookiecutter.tech_stack_summary }}""",
        "owner": """{{ cookiecutter.owner }}""",
        "owner_email": """{{ cookiecutter.owner_email }}""",
        "include_skills": """{{ cookiecutter.include_skills }}""",
        "include_optional_sections": """{{ cookiecutter.include_optional_sections }}""",
        "git_init": """{{ cookiecutter.git_init }}""",
    }
}

PROJECT = Path.cwd()
PRIMARY_LANG = CONTEXT["cookiecutter"]["primary_language"]
INCLUDE_SKILLS = CONTEXT["cookiecutter"]["include_skills"]
GIT_INIT = CONTEXT["cookiecutter"]["git_init"]
INCLUDE_OPTIONAL = CONTEXT["cookiecutter"]["include_optional_sections"]

# 文件后缀白名单:这些类型才扫描重渲染
RENDER_SUFFIXES = {".md", ".txt", ".yml", ".yaml", ".json", ".sh", ".py", ".toml", ".cfg"}
{% raw %}
JINJA_MARKER = re.compile(r"\{\{|\{%")
{% endraw %}


def re_render_unprocessed() -> int:
    """二次渲染:cookiecutter 因 binaryornot 误判而未处理的文件。"""
    from jinja2 import Template

    fixed = 0
    for path in PROJECT.rglob("*"):
        if not path.is_file():
            continue
        if ".git" in path.parts:
            continue
        if path.suffix.lower() not in RENDER_SUFFIXES:
            continue
        try:
            content = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        if not JINJA_MARKER.search(content):
            continue
        try:
            rendered = Template(content, keep_trailing_newline=True).render(**CONTEXT)
        except Exception as exc:
            print(f"[post_gen] WARN re-render failed for {path.relative_to(PROJECT)}: {exc}")
            continue
        if rendered != content:
            path.write_text(rendered, encoding="utf-8")
            print(f"[post_gen] re-rendered: {path.relative_to(PROJECT)}")
            fixed += 1
    return fixed


def maybe_drop_skills() -> None:
    if INCLUDE_SKILLS == "no":
        skills_dir = PROJECT / ".claude"
        if skills_dir.exists():
            shutil.rmtree(skills_dir)
            print("[post_gen] include_skills=no -> removed .claude/")


def maybe_git_init() -> None:
    if GIT_INIT != "yes":
        return
    try:
        subprocess.run(["git", "init", "--quiet"], check=True)
        subprocess.run(["git", "add", "-A"], check=True)
        print("[post_gen] git initialized")
    except (FileNotFoundError, subprocess.CalledProcessError) as exc:
        print(f"[post_gen] WARN: git init skipped ({exc})")


def main() -> None:
    fixed = re_render_unprocessed()
    if fixed:
        print(f"[post_gen] re-rendered {fixed} file(s) that binaryornot mis-detected")

    maybe_drop_skills()
    maybe_git_init()

    print()
    print(f"  Project   : {CONTEXT['cookiecutter']['project_name']}")
    print(f"  Language  : {PRIMARY_LANG}")
    print(f"  Owner     : {CONTEXT['cookiecutter']['owner']} <{CONTEXT['cookiecutter']['owner_email']}>")
    print(f"  Optional  : {INCLUDE_OPTIONAL}")
    print()
    print("Next steps:")
    print(f"  1. cd {CONTEXT['cookiecutter']['project_slug']}")
    print("  2. Read CLAUDE.md, fill in 项目背景 / 系统架构 / 技术栈 三节")
    print("  3. cruft check   (anytime, see if playbook has updates)")
    print("  4. cruft update  (apply playbook updates with 3-way merge)")


if __name__ == "__main__":
    main()
