# Install Game-Dev-Agentic-Skills (jalur Godot) + info Godot MCP (Windows PowerShell).
# Jalankan dari folder mana saja. Butuh: Node.js + Git.
# Lihat docs/GDAS_MCP_INSTALL.md untuk penjelasan lengkap.
Write-Host "Menginstall GDAS godot-master (satu jalur saja, sesuai README GDAS)..." -ForegroundColor Cyan
npx skills add thedivergentai/Game-Dev-Agentic-Skills/skills/godot-master
Write-Host ""
Write-Host "Godot MCP tidak perlu diinstall terpisah: Cursor memakai .cursor/mcp.json di project ini (npx @coding-solo/godot-mcp)." -ForegroundColor Green
Write-Host "Untuk Claude Code, jalankan: claude mcp add godot -- npx @coding-solo/godot-mcp" -ForegroundColor Green
Write-Host "Pastikan Godot ada di PATH, atau isi GODOT_PATH di konfigurasi MCP kamu." -ForegroundColor Yellow
