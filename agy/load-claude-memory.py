#!/usr/bin/env python3
"""Antigravity SessionStart hook: share ~/.claude/projects/*/memory with agy
and bridge project-level CLAUDE.md when AGENTS.md / GEMINI.md is absent."""

import json
import os
import re
import subprocess
import sys

CLAUDE_PROJECTS = os.path.expanduser("~/.claude/projects")
HOME = os.path.realpath(os.path.expanduser("~"))
HOME_ABS = os.path.abspath(os.path.expanduser("~"))
MAX_INLINE_CLAUDE_MD = 24000
LINK_RE = re.compile(r"\[([^\]]+)\]\((?!https?://|file://|/)([^)\s]+)\)")


def encode_path(p: str) -> str:
    return re.sub(r"[^a-zA-Z0-9]", "-", p)


def git_toplevel(p: str) -> str:
    try:
        res = subprocess.run(
            ["git", "-C", p, "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            timeout=2,
        )
        if res.returncode == 0 and res.stdout.strip():
            return os.path.abspath(res.stdout.strip())
    except Exception:
        pass
    return ""


def ancestor_chain(target: str) -> list[str]:
    """Return paths from general to specific (stopping at HOME if under HOME, else /Volumes/<vol>)."""
    target = os.path.abspath(target)
    chain = []
    cur = target
    while True:
        chain.append(cur)
        if cur in (HOME_ABS, HOME, "/"):
            break
        parent = os.path.dirname(cur)
        if parent == cur or parent in ("/", "/Users", "/Volumes"):
            break
        cur = parent
    chain.reverse()
    return chain


def rewrite_links(text: str, proj_store: str) -> str:
    mem_dir = os.path.join(proj_store, "memory")

    def repl(m: re.Match) -> str:
        label, rel = m.group(1), m.group(2)
        cand_mem = os.path.join(mem_dir, rel)
        cand_root = os.path.join(proj_store, rel)
        target = cand_mem if os.path.exists(cand_mem) else (cand_root if os.path.exists(cand_root) else cand_mem)
        return f"[{label}](file://{target})"

    return LINK_RE.sub(repl, text)


def load_memory_for_dir(d: str) -> list[tuple[str, str]]:
    """Return list of (source_path, rewritten_markdown) for directory d."""
    results = []
    seen_real = set()
    candidates = [d]
    rp = os.path.realpath(d)
    if rp != d:
        candidates.append(rp)

    for cand in candidates:
        enc = encode_path(cand)
        proj_store = os.path.join(CLAUDE_PROJECTS, enc)
        if not os.path.isdir(proj_store):
            continue
        for rel_idx in ("memory/MEMORY.md", "MEMORY.md"):
            idx_path = os.path.join(proj_store, rel_idx)
            if not os.path.isfile(idx_path):
                continue
            real_idx = os.path.realpath(idx_path)
            if real_idx in seen_real:
                continue
            seen_real.add(real_idx)
            try:
                raw = open(idx_path, encoding="utf-8", errors="replace").read().strip()
            except OSError:
                continue
            if raw:
                results.append((idx_path, rewrite_links(raw, proj_store)))
    return results


def needs_claude_md_bridge(root: str) -> bool:
    claude_md = os.path.join(root, "CLAUDE.md")
    if not os.path.isfile(claude_md):
        return False
    if os.path.abspath(root) in (HOME_ABS, HOME):
        return False
    gemini_md = os.path.join(root, "GEMINI.md")
    agents_md = os.path.join(root, "AGENTS.md")
    if os.path.isfile(gemini_md) and os.path.getsize(gemini_md) > 0:
        return False
    if os.path.isfile(agents_md):
        try:
            sz = os.path.getsize(agents_md)
            if sz >= 100:
                return False
            stub = open(agents_md, encoding="utf-8", errors="replace").read()
            if "@CLAUDE.md" in stub and "@[" not in stub:
                return True
            return sz == 0
        except OSError:
            return False
    return True


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        payload = {}

    raw_roots = []
    cwd = payload.get("cwd")
    if isinstance(cwd, str) and cwd.strip():
        raw_roots.append(cwd.strip())
    ws_paths = payload.get("workspacePaths")
    if isinstance(ws_paths, list):
        for p in ws_paths:
            if isinstance(p, str) and p.strip():
                raw_roots.append(p.strip())
    if not raw_roots:
        raw_roots.append(os.getcwd())

    roots = []
    for r in raw_roots:
        ap = os.path.abspath(os.path.expanduser(r))
        top = git_toplevel(ap) if os.path.isdir(ap) else ""
        if top and top not in roots:
            roots.append(top)
        if ap not in roots:
            roots.append(ap)

    primary_root = roots[0]
    visited_dirs = []
    for r in roots:
        for anc in ancestor_chain(r):
            if anc not in visited_dirs:
                visited_dirs.append(anc)

    sections = []

    # 1. Project CLAUDE.md bridge when AGENTS.md / GEMINI.md is missing or @CLAUDE.md stub
    if os.path.isdir(primary_root) and needs_claude_md_bridge(primary_root):
        claude_md_path = os.path.join(primary_root, "CLAUDE.md")
        try:
            sz = os.path.getsize(claude_md_path)
            if sz <= MAX_INLINE_CLAUDE_MD:
                body = open(claude_md_path, encoding="utf-8", errors="replace").read().strip()
                if body:
                    sections.append(
                        f"## Project Instructions (bridged from file://{claude_md_path})\n\n{body}"
                    )
            else:
                sections.append(
                    f"## Project Instructions\n\nThis repository defines instructions in "
                    f"[CLAUDE.md](file://{claude_md_path}) ({sz} bytes). Read it with `read_file` before making changes."
                )
        except OSError:
            pass

    # 2. Shared Claude/AGY memories along ancestor -> project chain
    mem_blocks = []
    seen_sources = set()
    for d in visited_dirs:
        for src_path, content in load_memory_for_dir(d):
            if src_path in seen_sources:
                continue
            seen_sources.add(src_path)
            mem_blocks.append(f"### Scope: `{d}` ([MEMORY.md](file://{src_path}))\n{content}")

    primary_enc = encode_path(primary_root)
    primary_mem_dir = os.path.join(CLAUDE_PROJECTS, primary_enc, "memory")

    if mem_blocks:
        header = (
            "## Shared Project & Infrastructure Memory (Claude Code <-> Antigravity)\n"
            "Index entries below point to detailed memory files. Use `read_file` on any relevant `file://` link before acting on that topic.\n"
            f"Active scope memory directory for saving/updating memories: `{primary_mem_dir}` (`MEMORY.md` + `<topic>.md`)."
        )
        sections.append(header + "\n\n" + "\n\n".join(mem_blocks))

    if not sections:
        print("{}")
        return

    out = {
        "injectSteps": [
            {
                "systemMessage": {
                    "systemMessage": "\n\n---\n\n".join(sections)
                }
            }
        ]
    }
    print(json.dumps(out, ensure_ascii=False))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        print("{}")
