#!/usr/bin/env python3
"""Generate reusable prop scenes in scenes/props/ from a prop table.
Each scene: Node2D root (prop.gd) + Gambar (Sprite2D) + Collision (StaticBody2D, if solid).
Collision sizes are the REDUCED (game-feel) sizes, inset from the sprite.
Sprite offset follows the level rule: (0, -h/2 + 16).
Run from the repo root: python3 tools/make_prop_scenes.py
"""
import os
from PIL import Image

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(REPO, "scenes", "props")
PROP_BASE = "assets/office_assets/main/Office_Pixel_Art_Free_v1.0/Props/"
MODERN_BASE = "assets/office_assets/modern/objects/"
SCRIPT = "res://scripts/prop.gd"

# name, texture res path, collision (w,h) or None, is_hide_spot
PROPS = [
    ("Meja", PROP_BASE + "Desks/office_desk/office_desk_front.png", (56, 18), True),
    ("Kursi_Depan", PROP_BASE + "Seating/office_chair/office_chair_front.png", (20, 14), False),
    ("Kursi_Belakang", PROP_BASE + "Seating/office_chair/office_chair_back.png", (20, 14), False),
    ("Kursi_Kiri", PROP_BASE + "Seating/office_chair/office_chair_left.png", (20, 14), False),
    ("Kursi_Kanan", PROP_BASE + "Seating/office_chair/office_chair_right.png", (20, 14), False),
    ("Komputer", PROP_BASE + "Tech/computer/computer_front.png", None, False),
    ("Laptop", PROP_BASE + "Tech/laptop/laptop_front.png", None, False),
    ("Lemari", PROP_BASE + "Storage/filing_cabinet/filing_cabinet_front.png", (24, 18), False),
    ("Tanaman", PROP_BASE + "Decor/office_plant/office_plant_front.png", (20, 12), False),
    ("Tanaman_Tinggi", PROP_BASE + "Decor/tall_plant/tall_plant_front.png", (14, 12), False),
    ("Jam_Dinding", PROP_BASE + "Decor/wall_clock/wall_clock_front.png", None, False),
    ("Dispenser", PROP_BASE + "Kitchen/water_cooler/water_cooler_left.png", (16, 12), False),
    ("Tempat_Sampah", PROP_BASE + "Kitchen/trash_bin/trash_bin_front.png", (12, 10), False),
    ("Lampu_Meja", PROP_BASE + "Desk_Items/desk_lamp/desk_lamp_front.png", None, False),
    ("Mug", PROP_BASE + "Desk_Items/coffee_mug/coffee_mug_front.png", None, False),
    ("Tumpukan_Kertas", PROP_BASE + "Desk_Items/paper_stack/paper_stack_front.png", None, False),
    ("Meja_Rapat", PROP_BASE + "Meeting/conference_table/conference_table_front.png", (88, 32), True),
    ("Flipchart", PROP_BASE + "Meeting/flip_chart/flip_chart_right.png", (20, 10), False),
    ("Layar_Proyektor", PROP_BASE + "Meeting/projector_screen/projector_screen_front.png", None, False),
    ("Papan_Tulis", MODERN_BASE + "whiteboard.png", None, False),
    ("Sofa", MODERN_BASE + "sofa.png", (38, 16), False),
    ("Rak_Buku", MODERN_BASE + "bookshelf.png", (26, 16), False),
]

def main() -> None:
    os.makedirs(OUT, exist_ok=True)
    for name, tex_rel, col, hide in PROPS:
        tex_res = "res://" + tex_rel
        tex_abs = os.path.join(REPO, tex_rel)
        if not os.path.exists(tex_abs):
            print(f"SKIP {name}: texture not found: {tex_rel}")
            continue
        with Image.open(tex_abs) as im:
            w, h = im.size
        off_y = -h / 2.0 + 16
        # format offset: integer when whole, else one decimal
        off_str = str(int(off_y)) if off_y == int(off_y) else f"{off_y:.1f}"
        solid = col is not None
        steps = 4 if solid else 3
        lines = []
        lines.append(f'[gd_scene load_steps={steps} format=4]')
        lines.append("")
        lines.append(f'[ext_resource type="Script" path="{SCRIPT}" id="1_prop"]')
        lines.append(f'[ext_resource type="Texture2D" path="{tex_res}" id="2_tex"]')
        lines.append("")
        if solid:
            lines.append('[sub_resource type="RectangleShape2D" id="RectangleShape2D_col"]')
            lines.append(f"size = Vector2({col[0]}, {col[1]})")
            lines.append("")
        lines.append(f'[node name="{name}" type="Node2D"]')
        lines.append('script = ExtResource("1_prop")')
        if hide:
            lines.append("is_hide_spot = true")
        lines.append("")
        lines.append('[node name="Gambar" type="Sprite2D" parent="."]')
        lines.append('texture = ExtResource("2_tex")')
        lines.append(f"position = Vector2(0, {off_str})")
        lines.append("")
        if solid:
            lines.append('[node name="Collision" type="StaticBody2D" parent="."]')
            lines.append("collision_layer = 1")
            lines.append("collision_mask = 0")
            lines.append("")
            lines.append('[node name="CollisionShape2D" type="CollisionShape2D" parent="Collision"]')
            lines.append("position = Vector2(0, 8)")
            lines.append('shape = SubResource("RectangleShape2D_col")')
            lines.append("")
        fname = name.lower() + ".tscn"
        path = os.path.join(OUT, fname)
        with open(path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))
        col_str = f"{col[0]}x{col[1]}" if solid else "none"
        print(f"{fname}: sprite {w}x{h}, offset (0,{off_str}), collision {col_str}, hide={hide}")

if __name__ == "__main__":
    main()
