#!/usr/bin/env bash
# Install Game-Dev-Agentic-Skills (jalur Godot) + info Godot MCP (macOS/Linux).
# Butuh: Node.js + Git. Lihat docs/GDAS_MCP_INSTALL.md untuk penjelasan lengkap.
set -euo pipefail
echo "Menginstall GDAS godot-master (satu jalur saja, sesuai README GDAS)..."
npx skills add thedivergentai/Game-Dev-Agentic-Skills/skills/godot-master
echo ""
echo "Godot MCP tidak perlu diinstall terpisah: Cursor memakai .cursor/mcp.json di project ini (npx @coding-solo/godot-mcp)."
echo "Untuk Claude Code, jalankan: claude mcp add godot -- npx @coding-solo/godot-mcp"
echo "Pastikan Godot ada di PATH, atau isi GODOT_PATH di konfigurasi MCP kamu."
