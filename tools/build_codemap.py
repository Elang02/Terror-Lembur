#!/usr/bin/env python3
"""Build a code map for the Terror Lembur Godot project.

GDScript has no tree-sitter grammar in engram/graphify, so this extractor
parses .gd files with regex and .tscn scenes structurally, and writes:
  .planning/codemap.json  - queryable graph (nodes + edges)
  .planning/CODEMAP.md    - human-readable summary

Usage: python3 tools/build_codemap.py [--query <name>]
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_JSON = ROOT / ".planning" / "codemap.json"
OUT_MD = ROOT / ".planning" / "CODEMAP.md"

FUNC_RE = re.compile(r"^\s*(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(")
CLASS_RE = re.compile(r"^\s*class_name\s+([A-Za-z_][A-Za-z0-9_]*)")
EXTENDS_RE = re.compile(r"^\s*extends\s+([A-Za-z_][A-Za-z0-9_./]*)")
SIGNAL_RE = re.compile(r"^\s*signal\s+([A-Za-z_][A-Za-z0-9_]*)")
CONST_RE = re.compile(r"^\s*const\s+([A-Z_][A-Z0-9_]*)")
VAR_RE = re.compile(r"^\s*(?:@export\s+)?var\s+([A-Za-z_][A-Za-z0-9_]*)")
CALL_RE = re.compile(r"([A-Za-z_][A-Za-z0-9_]*)\s*\(")
EMIT_RE = re.compile(r"emit_signal\(\s*\"?([A-Za-z_][A-Za-z0-9_]*)\"?")
RPC_RE = re.compile(r"\.rpc\(\s*\"([A-Za-z_][A-Za-z0-9_]*)\"")
LOAD_RE = re.compile(r"(?:load|preload)\(\s*\"(res://[^\"]+)\"")

GD_KEYWORDS = {
    "if", "elif", "else", "for", "while", "match", "return", "break",
    "continue", "pass", "and", "or", "not", "in", "is", "await", "yield",
    "func", "var", "const", "class", "extends", "signal", "enum", "static",
    "print", "push_error", "push_warning", "assert", "super", "self",
    "true", "false", "null", "void", "int", "float", "String", "bool",
    "Vector2", "Vector2i", "Vector3", "Color", "Rect2", "Array", "Dictionary",
}


def parse_gd(path: Path) -> dict:
    text = path.read_text(errors="replace")
    lines = text.splitlines()
    info = {
        "path": str(path.relative_to(ROOT)),
        "class_name": None,
        "extends": None,
        "signals": [],
        "consts": [],
        "vars": [],
        "funcs": {},
        "loads": sorted(set(LOAD_RE.findall(text))),
    }
    cur_func = None
    for i, line in enumerate(lines, 1):
        m = CLASS_RE.match(line)
        if m:
            info["class_name"] = m.group(1)
        m = EXTENDS_RE.match(line)
        if m:
            info["extends"] = m.group(1)
        m = SIGNAL_RE.match(line)
        if m:
            info["signals"].append((m.group(1), i))
        m = CONST_RE.match(line)
        if m:
            info["consts"].append((m.group(1), i))
        m = VAR_RE.match(line)
        if m and cur_func is None:
            info["vars"].append((m.group(1), i))
        m = FUNC_RE.match(line)
        if m:
            cur_func = m.group(1)
            info["funcs"][cur_func] = {"line": i, "calls": set(), "emits": set(), "rpcs": set()}
            continue
        if cur_func is not None:
            if line.strip() and not line[0].isspace() and not line.startswith("\t"):
                cur_func = None
            else:
                for c in CALL_RE.findall(line):
                    if c not in GD_KEYWORDS and c != cur_func:
                        info["funcs"][cur_func]["calls"].add(c)
                for e in EMIT_RE.findall(line):
                    info["funcs"][cur_func]["emits"].add(e)
                for r in RPC_RE.findall(line):
                    info["funcs"][cur_func]["rpcs"].add(r)
    for f in info["funcs"].values():
        f["calls"] = sorted(f["calls"])
        f["emits"] = sorted(f["emits"])
        f["rpcs"] = sorted(f["rpcs"])
    return info


def parse_tscn(path: Path) -> dict:
    text = path.read_text(errors="replace")
    nodes = []
    script = None
    for line in text.splitlines():
        m = re.match(r'\[node name="([^"]+)" type="([^"]+)"', line)
        if m:
            nodes.append({"name": m.group(1), "type": m.group(2)})
        m = re.search(r'script\s*=\s*ExtResource\("([^"]+)"\)', line)
        if m:
            script = m.group(1)
    ext = re.findall(r'\[ext_resource type="Script" path="([^"]+)"', text)
    return {
        "path": str(path.relative_to(ROOT)),
        "nodes": nodes,
        "scripts": ext,
        "root": nodes[0] if nodes else None,
    }


def build() -> dict:
    files = {}
    for p in sorted(ROOT.rglob("*.gd")):
        if ".git" in p.parts:
            continue
        files[str(p.relative_to(ROOT))] = parse_gd(p)
    scenes = {}
    for p in sorted(ROOT.rglob("*.tscn")):
        if ".git" in p.parts:
            continue
        scenes[str(p.relative_to(ROOT))] = parse_tscn(p)
    nodes = []
    edges = []
    func_index = {}
    for fpath, f in files.items():
        nodes.append({"id": f"file:{fpath}", "kind": "file", "label": fpath})
        if f["class_name"]:
            nodes.append({"id": f"class:{f['class_name']}", "kind": "class", "label": f["class_name"], "file": fpath})
            edges.append({"from": f"file:{fpath}", "to": f"class:{f['class_name']}", "kind": "defines"})
        if f["extends"]:
            edges.append({"from": f"file:{fpath}", "to": f"extends:{f['extends']}", "kind": "extends"})
        for sig, line in f["signals"]:
            nodes.append({"id": f"signal:{fpath}#{sig}", "kind": "signal", "label": sig, "file": fpath, "line": line})
        for fname, fd in f["funcs"].items():
            fid = f"func:{fpath}#{fname}"
            func_index[fname] = func_index.get(fname, []) + [fid]
            nodes.append({"id": fid, "kind": "func", "label": fname, "file": fpath, "line": fd["line"]})
            edges.append({"from": f"file:{fpath}", "to": fid, "kind": "defines"})
            for e in fd["emits"]:
                edges.append({"from": fid, "to": f"signal:{fpath}#{e}", "kind": "emits"})
            for r in fd["rpcs"]:
                edges.append({"from": fid, "to": f"rpc:{r}", "kind": "rpc"})
    for fname, fids in func_index.items():
        for fpath, f in files.items():
            for gname, fd in f["funcs"].items():
                if fname in fd["calls"]:
                    src = f"func:{fpath}#{gname}"
                    for tgt in fids:
                        if tgt != src:
                            edges.append({"from": src, "to": tgt, "kind": "calls"})
    for spath, s in scenes.items():
        nodes.append({"id": f"scene:{spath}", "kind": "scene", "label": spath, "root": s["root"]})
        for scr in s["scripts"]:
            edges.append({"from": f"scene:{spath}", "to": f"file:{scr}", "kind": "attaches"})
    graph = {"nodes": nodes, "edges": edges, "files": files, "scenes": scenes}
    return graph


def write_md(graph: dict) -> None:
    files = graph["files"]
    scenes = graph["scenes"]
    total_funcs = sum(len(f["funcs"]) for f in files.values())
    total_signals = sum(len(f["signals"]) for f in files.values())
    lines = [
        "# CODEMAP — Terror Lembur",
        "",
        "Dibangun otomatis oleh `tools/build_codemap.py` (GDScript tidak didukung tree-sitter engram/graphify, jadi extractor ini regex + struktural).",
        "Sumber query: `.planning/codemap.json`. Regenerasi: `python3 tools/build_codemap.py`.",
        "",
        f"- File .gd: {len(files)}, fungsi: {total_funcs}, signal: {total_signals}, scene .tscn: {len(scenes)}",
        "",
        "## File script utama",
        "",
    ]
    core = [p for p in files if p.startswith("scripts/")]
    for p in sorted(core):
        f = files[p]
        funcs = ", ".join(f["funcs"]) or "-"
        lines.append(f"- `{p}` — class `{f['class_name'] or '-'}` extends `{f['extends'] or '-'}`")
        lines.append(f"  - funcs ({len(f['funcs'])}): {funcs}")
        if f["signals"]:
            lines.append(f"  - signals: {', '.join(s for s, _ in f['signals'])}")
    lines += ["", "## Scene", ""]
    for p in sorted(scenes):
        s = scenes[p]
        root = s["root"]
        r = f"{root['name']} ({root['type']})" if root else "-"
        scr = ", ".join(f"`{x}`" for x in s["scripts"]) or "-"
        lines.append(f"- `{p}` — root {r}, {len(s['nodes'])} node, script: {scr}")
    lines += ["", "## Tools", ""]
    tools = [p for p in files if p.startswith("tools/")]
    for p in sorted(tools):
        lines.append(f"- `{p}` — {len(files[p]['funcs'])} funcs")
    OUT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")


def query(graph: dict, name: str) -> None:
    files = graph["files"]
    print(f"== {name} ==")
    for fpath, f in files.items():
        if name in f["funcs"]:
            fd = f["funcs"][name]
            print(f"DEF {fpath}:{fd['line']} func {name}")
            if fd["calls"]:
                print(f"  calls: {', '.join(fd['calls'])}")
            if fd["emits"]:
                print(f"  emits: {', '.join(fd['emits'])}")
            if fd["rpcs"]:
                print(f"  rpc: {', '.join(fd['rpcs'])}")
    callers = []
    for fpath, f in files.items():
        for gname, fd in f["funcs"].items():
            if name in fd["calls"]:
                callers.append(f"{fpath}#{gname}:{fd['line']}")
    if callers:
        print("CALLERS:")
        for c in sorted(set(callers)):
            print(f"  {c}")
    for fpath, f in files.items():
        if f["class_name"] == name:
            print(f"CLASS {name} in {fpath}, extends {f['extends']}")
        for sig, line in f["signals"]:
            if sig == name:
                print(f"SIGNAL {name} in {fpath}:{line}")


def main() -> None:
    if len(sys.argv) >= 3 and sys.argv[1] == "--query":
        graph = json.loads(OUT_JSON.read_text())
        query(graph, sys.argv[2])
        return
    graph = build()
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUT_JSON.write_text(json.dumps(graph, indent=1, sort_keys=True), encoding="utf-8")
    write_md(graph)
    n = len(graph["nodes"])
    e = len(graph["edges"])
    print(f"codemap: {len(graph['files'])} gd files, {len(graph['scenes'])} scenes, {n} nodes, {e} edges")
    print(f"wrote {OUT_JSON} and {OUT_MD}")


if __name__ == "__main__":
    main()
