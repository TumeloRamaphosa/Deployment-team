#!/usr/bin/env python3
"""Validate the Skills Vault: every skill and agent has well-formed frontmatter."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
errors: list[str] = []


def frontmatter(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        errors.append(f"{path}: missing frontmatter")
        return {}
    block = text[4:].split("\n---", 1)[0]
    out: dict[str, str] = {}
    for line in block.splitlines():
        if ":" in line and not line.startswith(" "):
            k, v = line.split(":", 1)
            out[k.strip()] = v.strip()
    return out


skills = sorted(ROOT.glob("skills/*/SKILL.md"))
for p in skills:
    fm = frontmatter(p)
    name, desc = fm.get("name", ""), fm.get("description", "")
    if name != p.parent.name:
        errors.append(f"{p}: name '{name}' must equal folder '{p.parent.name}'")
    if not NAME_RE.match(name) or len(name) > 64:
        errors.append(f"{p}: name must be lowercase-hyphenated, <=64 chars")
    if not desc or len(desc) > 1024:
        errors.append(f"{p}: description required, <=1024 chars")

agents = sorted(ROOT.glob("agents/*.agent.md"))
for p in agents:
    fm = frontmatter(p)
    expected = p.name.removesuffix(".agent.md")
    if fm.get("name") != expected:
        errors.append(f"{p}: name must be '{expected}'")
    if not fm.get("description"):
        errors.append(f"{p}: description required")
    if len(p.read_text(encoding="utf-8")) > 30000:
        errors.append(f"{p}: agent prompt over 30k chars")

if errors:
    print("\n".join(errors))
    sys.exit(1)
print(f"vault ok: {len(skills)} skills, {len(agents)} agents")
