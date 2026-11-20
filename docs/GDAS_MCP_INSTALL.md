# Instalasi: Game-Dev-Agentic-Skills + Godot MCP

Panduan ini untuk PC pengembangan (Windows/macOS/Linux). Keduanya
**opsional** — game jalan tanpa keduanya. Mereka hanya membantu AI
coding assistant (Claude Code / Cursor / Cline / sejenis) bekerja
dengan project Godot ini.

Yang sudah terpasang di workspace Muse (bukan di PC kamu): clone
GDAS + build Godot MCP sudah ada dan dipakai untuk membangun base ini.
Ikuti langkah di bawah untuk memasangnya di PC kamu sendiri.

## 1. Game-Dev-Agentic-Skills (GDAS)

Pustaka skill Godot 4.7+ / Bevy 0.20+ (184 skill).
Repo: https://github.com/thedivergentai/Game-Dev-Agentic-Skills

**Penting dari README-nya: install SATU jalur saja, jangan `--all`.**
Menginstall semua skill sekaligus membanjiri konteks agent
("Context Storm").

### Opsi A — via `npx skills` (disarankan)

Butuh Node.js. Di terminal, dari folder mana saja:

```bash
# Jalur Godot (hub utama — cukup ini untuk Terror Lembur):
npx skills add thedivergentai/Game-Dev-Agentic-Skills/skills/godot-master

# Atau SATU domain skill saja, misalnya:
npx skills add thedivergentai/Game-Dev-Agentic-Skills/skills/godot-tilemap-mastery
```

Domain skill yang paling relevan untuk game ini:

| Skill | Dipakai untuk |
|---|---|
| `godot-master` | Hub/orchestrator semua skill Godot |
| `godot-tilemap-mastery` | TileMap, terrain, physics tile |
| `godot-multiplayer-networking` | ENet, RPC aman, sinkronisasi |
| `godot-genre-horror` | Pacing horor, predator AI, Director |
| `godot-genre-stealth` | Sembunyi & deteksi |
| `godot-characterbody-2d` | Controller pemain/enemy |
| `godot-ai-navigation` | Pathfinding / NavigationAgent |
| `godot-mechanic-revival` | Mati → revive / checkpoint |
| `godot-quest-system` | Sistem tugas/objective |
| `godot-camera-systems` | Kamera + screen shake |

### Opsi B — clone manual (referensi saja)

```bash
git clone https://github.com/thedivergentai/Game-Dev-Agentic-Skills.git
```

Lalu baca `skills/godot-master/SKILL.md` dan domain skill yang
dibutuhkan. Cara ini tidak "menginstall" ke agent — hanya referensi
yang bisa dibaca/dicari.

## 2. Godot MCP (Coding-Solo)

MCP server (Node.js/TypeScript) yang membuat AI assistant bisa membuka
editor Godot, menjalankan project, membaca output debug, dan mengelola
scene — lewat Model Context Protocol.
Repo: https://github.com/Coding-Solo/godot-mcp (MIT)
Paket npm: `@coding-solo/godot-mcp`

Syarat: **Godot terinstall** + **Node.js ≥ 18**.

### Claude Code

```bash
claude mcp add godot -- npx @coding-solo/godot-mcp
# Dengan path Godot eksplisit (ganti sesuai instalasi kamu):
claude mcp add godot -e GODOT_PATH="C:/Program Files/Godot/godot.exe" -- npx @coding-solo/godot-mcp
```

Restart Claude Code setelahnya.

### Cursor

Project ini sudah berisi `.cursor/mcp.json`:

```json
{
  "mcpServers": {
	"godot": {
	  "command": "npx",
	  "args": ["@coding-solo/godot-mcp"],
	  "env": { "DEBUG": "true" }
	}
  }
}
```

Buka project di Cursor → Settings → Features → MCP → refresh.
Kalau Godot tidak ada di PATH, tambahkan
`"GODOT_PATH": "C:/.../godot.exe"` (Windows) atau path binary Godot
kamu di `env`.

Atau lewat UI Cursor: Settings → Features → MCP → Add New MCP Server →
Name `godot`, Type `command`, Command `npx @coding-solo/godot-mcp`.

### Cline / MCP client lain

Tambahkan ke file konfigurasi MCP client kamu:

```json
{
  "mcpServers": {
	"godot": {
	  "command": "npx",
	  "args": ["@coding-solo/godot-mcp"],
	  "env": { "GODOT_PATH": "/path/ke/godot", "DEBUG": "true" },
	  "disabled": false,
	  "autoApprove": [
		"launch_editor", "run_project", "get_debug_output",
		"stop_project", "get_godot_version", "list_projects",
        "get_project_info"
	  ]
	}
  }
}
```

### Build dari source (opsional)

```bash
git clone https://github.com/Coding-Solo/godot-mcp.git
cd godot-mcp
npm install
npm run build
# Jalankan: node build/index.js
```

### Catatan

- Godot MCP adalah project komunitas (bukan resmi Godot Engine).
  Ia berjalan lokal (stdio) dan berbicara dengan binary Godot kamu.
- Ada banyak fork `godot-mcp` (Vollkorn-Games, ChanceFlow, dsb.) dengan
  fitur berbeda. Yang dipakai di sini adalah yang asli dari Coding-Solo
  karena paling banyak direferensikan dan punya paket npm resmi.
  Kalau butuh fitur lebih (edit scene mendalam, 75 tools), evaluasi
  fork Vollkorn-Games sebagai pengganti — jangan install dua-duanya
  dengan nama server yang sama.
- GDAS sendiri (v0.0.7+) menghapus skill MCP-nya dan lebih memilih
  membangun langsung via Godot CLI. Godot MCP tetap berguna untuk
  iterasi cepat di editor; untuk build/tes otomatis, pakai CLI:
  `godot --headless --import`, smoke test, dan export.

## 3. Superpowers (untuk Muse — sudah terpasang)

Superpowers (https://github.com/obra/superpowers) adalah metodologi
pengembangan untuk coding agent (brainstorming, writing-plans,
executing-plans, TDD, systematic-debugging, verification, dll.).
15 skill-nya sudah dipasang sebagai custom skill Muse di workspace ini
(`~/workspace/custom-skills/superpowers-*/`) dan bisa dicari Muse
kapan saja. Tidak ada yang perlu diinstall di PC kamu untuk ini,
kecuali kamu juga memakai Superpowers di Claude Code/Cursor — ikuti
README repo tersebut per harness.
