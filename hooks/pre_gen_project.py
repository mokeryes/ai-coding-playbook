#!/usr/bin/env python
"""cookiecutter pre-generation hook: validate variables before creating files."""

import re
import sys

project_slug = "{{ cookiecutter.project_slug }}"
owner_email = "{{ cookiecutter.owner_email }}"

if not re.match(r"^[a-z][a-z0-9\-]*$", project_slug):
    sys.stderr.write(
        f"ERROR: project_slug '{project_slug}' is invalid.\n"
        "  Must be lowercase letters/digits/hyphens, starting with a letter.\n"
    )
    sys.exit(1)

if owner_email and "@" not in owner_email:
    sys.stderr.write(
        f"ERROR: owner_email '{owner_email}' looks invalid (no @).\n"
    )
    sys.exit(1)

print(f"[pre_gen] variables OK -> generating '{project_slug}'")
