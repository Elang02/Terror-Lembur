"""Generator Level 1 (Terror Lembur) dari pack asli itch.io.
Hasil: atlas PNG + TileSet .tres + scenes/level_1.tscn (tile sudah dicat, bisa diedit di Godot).
"""
import os, sys, base64, struct, json, shutil
import numpy as np
from PIL import Image, ImageDraw

PK = '/home/claude/packs'
IM = PK + '/Office_Pixel_Art_Free_v1.0/Office_Pixel_Art_Free_v1.0/'
RB = PK + '/modern-office-tileset-16x16-free-sample/'
NC = PK + '/ModernOffice2DProps_v1.0/ModernOffice2DProps_v1.0/Tiles/'
OUT = sys.argv[1] if len(sys.argv) > 1 else '/home/claude/out/TerrorLembur'
TDIR = 'assets/tiles/lembur'
T = 32
W, H = 64, 40

def rgba(p): return Image.open(p).convert('RGBA')

# ------------------------------------------------------------------ WALLS
WT = rgba(IM + 'Tilesets/Walls_Plain/office_walls_tileset.png')
def wt(i):
    c, r = i % 8, i // 8
    return np.array(WT.crop((c*T, r*T, c*T+T, r*T+T)))

def blank(): return np.zeros((T, T, 4), np.uint8)
def over(dst, src, x0=0, x1=T, y0=0, y1=T):
    s = src[y0:y1, x0:x1]; d = dst[y0:y1, x0:x1]
    a = s[..., 3:4] > 0
    dst[y0:y1, x0:x1] = np.where(a, s, d)
def fliph(a): return a[:, ::-1].copy()
def flipv(a): return a[::-1, :].copy()

# plan grids
rowtype = [[None]*W for _ in range(H)]   # 'cap','face','front'
strip = [[None]*W for _ in range(H)]     # 'L','M','R'

def back(r, c0, c1):
    for c in range(c0, c1+1):
        rowtype[r][c] = 'cap'; rowtype[r+1][c] = 'face'
def front(r, c0, c1):
    for c in range(c0, c1+1): rowtype[r][c] = 'front'
def vert(c, r0, r1, side='M'):
    for r in range(r0, r1+1): strip[r][c] = side
CARVED = set()
def carve(cells):
    for (c, r) in cells:
        CARVED.add((c, r))
        rowtype[r][c] = None; strip[r][c] = None
def carve_rect(c0, r0, c1, r1):
    carve([(c, r) for c in range(c0, c1+1) for r in range(r0, r1+1)])

def is_wall(c, r):
    if not (0 <= c < W and 0 <= r < H): return False
    return rowtype[r][c] is not None or strip[r][c] is not None

def wall_tile(c, r):
    rt = rowtype[r][c]; s = strip[r][c]
    st = lambda cc, rr: (0 <= rr < H and 0 <= cc < W and strip[rr][cc] is not None)
    rtt = lambda cc, rr: (0 <= rr < H and 0 <= cc < W and rowtype[rr][cc] == rt)
    hL, hR = rtt(c-1, r), rtt(c+1, r)
    img = blank()
    xs = {'L': (0, 16), 'M': (8, 24), 'R': (16, 32)}
    if rt in ('cap', 'face'):
        base = wt(2) if rt == 'cap' else wt(7)
        endL = wt(14) if rt == 'cap' else wt(18)
        endR = fliph(endL)
        # bagian kiri
        if hL: over(img, base, 0, 16)
        elif s is None: over(img, endL, 0, 16)
        elif s == 'M': pass
        if hR: over(img, base, 16, 32)
        elif s is None: over(img, endR, 16, 32)
        if s is not None:
            down = st(c, r+1) and (rt == 'face' or st(c, r+2))
            if rt == 'cap':
                src = {'L': wt(1), 'M': wt(3), 'R': wt(5)}[s]
                x0, x1 = xs[s]
                if down: over(img, src, x0, x1)
                else: over(img, wt(2), x0, x1, 0, 16)
                if s == 'L' and not hR: pass
            else:
                if down:
                    src = {'L': wt(6), 'M': wt(8), 'R': wt(10)}[s]
                    x0, x1 = xs[s]
                    over(img, src, x0, x1)
                else:
                    pass
        return img
    if rt == 'front':
        up = st(c, r-1)
        if s == 'L' and up: return wt(20).copy()
        if s == 'R' and up: return wt(24).copy()
        if hL: over(img, wt(23), 0, 16)
        elif s is None: over(img, wt(22), 0, 16)
        if hR: over(img, wt(23), 16, 32)
        elif s is None: over(img, wt(21), 16, 32)
        if s is not None:
            x0, x1 = xs[s]
            src = {'L': wt(11), 'M': wt(12), 'R': wt(13)}[s]
            if up: over(img, src, x0, x1, 0, 24)
            over(img, wt(23), x0, x1, 16, 32)
        return img
    # vertikal murni
    up, dn = st(c, r-1) or (0 <= r-1 and rowtype[r-1][c] in ('cap','face','front')), st(c, r+1) or (r+1 < H and rowtype[r+1][c] in ('cap','front'))
    full = {'L': wt(11), 'M': wt(12), 'R': wt(13)}[s]
    bot = {'L': wt(16), 'M': wt(17), 'R': fliph(wt(16))}[s]
    top = {'L': wt(19), 'M': flipv(wt(17)), 'R': fliph(wt(19))}[s]
    if up and dn: return full.copy()
    if up: return bot.copy()
    if dn: return top.copy()
    return bot.copy()

# ------------------------------------------------------------------ FLOORS
def rep16(p):
    t = rgba(p).resize((32, 32), Image.NEAREST); return t
FLOORS = {  # nama: (gambar, keterangan)
    'kayu':        (rgba(IM+'Tilesets/Floors/office_floors_tileset.png').crop((0,0,32,32)), 'Imersa kayu'),
    'karpet_abu':  (rgba(IM+'Tilesets/Floors/office_floors_tileset.png').crop((32,0,64,32)), 'Imersa karpet abu'),
    'ubin_terang': (rgba(IM+'Tilesets/Floors/office_floors_tileset.png').crop((64,0,96,32)), 'Imersa ubin terang'),
    'karpet_rapat':(rgba(IM+'Rooms/Meeting_Room/meeting_room_tileset.png').crop((0,0,32,32)), 'Imersa karpet ruang rapat'),
    'ubin_krem':   (WT.crop((0,0,32,32)), 'Imersa ubin krem'),
    'ubin_putih':  (rep16(RB+'tiles/floor_tile.png'), 'RubberStudio ubin putih (2x)'),
    'karpet_biru': (rep16(RB+'tiles/floor_carpet.png'), 'RubberStudio karpet biru (2x)'),
    'kayu_gelap':  (rep16(RB+'tiles/floor_wood.png'), 'RubberStudio kayu (2x)'),
}
FLOOR_ORDER = list(FLOORS.keys())

# ------------------------------------------------------------------ PROPS
def fit(im, w, h, smooth=False):
    bb = im.getbbox(); im = im.crop(bb)
    sw, sh = im.size
    k = min(w*T/sw, h*T/sh, 1.0 if not smooth else 99)
    if k < 1.0 or smooth:
        nw, nh = max(1, round(sw*k)), max(1, round(sh*k))
        im = im.resize((nw, nh), Image.LANCZOS if smooth else Image.NEAREST)
        if smooth:
            a = np.array(im); a[..., 3] = np.where(a[..., 3] > 110, 255, 0); im = Image.fromarray(a)
    can = Image.new('RGBA', (w*T, h*T))
    can.alpha_composite(im, ((w*T - im.width)//2, h*T - im.height))
    return can

def imersa(rel, w, h): return fit(rgba(IM+'Props/'+rel), w, h)
def rubber(n, w, h):
    im = rgba(RB+'objects/'+n+'.png'); im = im.resize((im.width*2, im.height*2), Image.NEAREST)
    return fit(im, w, h)
def nacl(rel, w, h, scale=1.0):
    im = rgba(NC+rel)
    bb = im.getbbox(); im = im.crop(bb)
    k = min(w*T/im.width, h*T/im.height) * scale
    im = im.resize((max(1, round(im.width*k)), max(1, round(im.height*k))), Image.LANCZOS)
    a = np.array(im); a[..., 3] = np.where(a[..., 3] > 110, 255, 0); im = Image.fromarray(a)
    can = Image.new('RGBA', (w*T, h*T)); can.alpha_composite(im, ((w*T-im.width)//2, h*T-im.height))
    return can

PROPS = {}  # nama: (Image, pack)
def P(name, im, pack): PROPS[name] = (im, pack)
P('meja_depan',   imersa('Desks/office_desk/office_desk_front.png', 2, 2), 'imersa')
P('meja_belakang',imersa('Desks/office_desk/office_desk_back.png', 2, 2), 'imersa')
P('kursi_hadap_bawah', imersa('Seating/office_chair/office_chair_front.png', 1, 2), 'imersa')
P('kursi_hadap_atas',  imersa('Seating/office_chair/office_chair_back.png', 1, 2), 'imersa')
P('tanaman',      imersa('Decor/office_plant/office_plant_front.png', 1, 2), 'imersa')
P('tanaman_tinggi', imersa('Decor/tall_plant/tall_plant_front.png', 1, 2), 'imersa')
P('lemari_arsip', imersa('Storage/filing_cabinet/filing_cabinet_front.png', 1, 2), 'imersa')
P('dispenser',    imersa('Kitchen/water_cooler/water_cooler_front.png', 1, 2), 'imersa')
P('tong_sampah',  imersa('Kitchen/trash_bin/trash_bin_front.png', 1, 1), 'imersa')
P('meja_rapat',   imersa('Meeting/conference_table/conference_table_front.png', 3, 3), 'imersa')
P('flipchart',    imersa('Meeting/flip_chart/flip_chart_front.png', 1, 2), 'imersa')
P('layar_proyektor', imersa('Meeting/projector_screen/projector_screen_front.png', 2, 1), 'imersa')
P('jam_dinding',  imersa('Decor/wall_clock/wall_clock_front.png', 1, 1), 'imersa')
P('tumpukan_kertas', imersa('Desk_Items/paper_stack/paper_stack_front.png', 1, 1), 'imersa')
P('komputer',     imersa('Tech/computer/computer_front.png', 1, 1), 'imersa')
P('rak_buku',     rubber('bookshelf', 2, 3), 'rubber')
P('tumpukan_boks', rubber('box_stack', 1, 2), 'rubber')
P('meja_monitor', rubber('desk_monitor', 2, 2), 'rubber')
P('meja_kecil',   rubber('desk', 2, 2), 'rubber')
P('sofa',         rubber('sofa', 3, 2), 'rubber')
P('tanaman_besar', rubber('plant_big', 2, 2), 'rubber')
P('lemari_kecil', rubber('filing_cabinet', 1, 2), 'rubber')
P('printer',      rubber('printer', 1, 1), 'rubber')
P('whiteboard',   fit(rgba(RB+'objects/whiteboard.png'), 1, 1), 'rubber')
P('jendela',      fit(rgba(RB+'objects/window.png'), 1, 1), 'rubber')
P('meja_kopi',    rubber('coffee_table', 2, 1), 'rubber')
P('kursi_r_bawah', rubber('chair_office_down', 1, 2), 'rubber')
P('tanaman_kecil', rubber('plant_small', 1, 1), 'rubber')
P('mesin_fotokopi', nacl('Electronics/office_electronics_copier_multifunction_01.png', 2, 2), 'nacl')
P('kulkas',       nacl('Decor/office_decor_refrigerator_compact_01.png', 1, 2), 'nacl')
P('rak_server',   nacl('Electronics/office_electronics_computer_tower_01.png', 1, 2), 'nacl')
P('ups',          nacl('Electronics/office_electronics_ups_01.png', 1, 1), 'nacl')
P('panel_listrik', nacl('Electronics/office_electronics_control_panel_01.png', 1, 1), 'nacl')
P('palem',        nacl('Decor/office_decor_plant_palm_01.png', 1, 2), 'nacl')
P('pohon_indoor', nacl('Decor/office_decor_tree_indoor_01.png', 1, 2), 'nacl')
P('partisi',      nacl('Decor/office_decor_partition_fabric_01.png', 2, 2), 'nacl')
P('meja_resepsionis', nacl('Furniture/office_furniture_counter_reception_curved_01.png', 3, 2), 'nacl')
P('lemari_tinggi', nacl('Furniture/office_furniture_cabinet_filing_tall_01.png', 1, 2), 'nacl')
P('kabinet_rendah', nacl('Furniture/office_furniture_credenza_low_01.png', 2, 2), 'nacl')
P('meja_proyek',  nacl('Furniture/office_furniture_desk_straight_01.png', 2, 2), 'nacl')
P('penghancur_kertas', nacl('Electronics/office_electronics_shredder_01.png', 1, 1), 'nacl')
P('boks_arsip',   nacl('Props/office_props_archive_box_01.png', 1, 1), 'nacl')
P('tempat_sampah_daurulang', nacl('Decor/office_decor_bin_recycling_01.png', 1, 1), 'nacl')
P('lampu_lantai', nacl('Electronics/office_electronics_lamp_floor_01.png', 1, 2), 'nacl')
P('lukisan',      nacl('Decor/office_decor_artwork_abstract_01.png', 1, 1, 0.8), 'nacl')
P('kamera_cctv',  nacl('Electronics/office_electronics_camera_security_01.png', 1, 1, 0.7), 'nacl')
P('kursi_tamu',   nacl('Furniture/office_furniture_chair_visitor_01.png', 1, 1), 'nacl')
# props yang ditempel di dinding (tanpa collision)
WALL_MOUNTED = {'layar_proyektor', 'jam_dinding', 'whiteboard', 'jendela', 'lukisan', 'kamera_cctv'}


# ------------------------------------------------------------ PROPS TAMBAHAN (v2)
P('meja_samping_kiri', imersa('Desks/office_desk/office_desk_left.png', 1, 3), 'imersa')
P('meja_samping_kanan', imersa('Desks/office_desk/office_desk_right.png', 1, 3), 'imersa')
P('kursi_hadap_kiri', imersa('Seating/office_chair/office_chair_left.png', 1, 2), 'imersa')
P('kursi_hadap_kanan', imersa('Seating/office_chair/office_chair_right.png', 1, 2), 'imersa')
P('meja_rapat_tegak', imersa('Meeting/conference_table/conference_table_left.png', 2, 4), 'imersa')
P('tanaman_b', imersa('Decor/office_plant/office_plant_left.png', 1, 2), 'imersa')
P('lemari_arsip_samping', imersa('Storage/filing_cabinet/filing_cabinet_left.png', 1, 2), 'imersa')
P('kursi_kerja', nacl('Furniture/office_furniture_chair_task_01.png', 1, 1), 'nacl')
P('kursi_rapat', nacl('Furniture/office_furniture_chair_meeting_01.png', 1, 1), 'nacl')
P('meja_sudut', nacl('Furniture/office_furniture_desk_corner_l_01.png', 2, 2), 'nacl')
P('meja_berdiri', nacl('Furniture/office_furniture_desk_standing_01.png', 2, 2), 'nacl')
P('meja_panel', nacl('Furniture/office_furniture_desk_modesty_panel_01.png', 2, 2), 'nacl')
P('laci_dorong', nacl('Furniture/office_furniture_pedestal_mobile_01.png', 1, 1), 'nacl')
P('kursi_bar', nacl('Furniture/office_furniture_stool_high_01.png', 1, 1), 'nacl')
P('tanaman_lebar', nacl('Decor/office_decor_plant_broadleaf_01.png', 1, 2), 'nacl')
P('tanaman_lidah', nacl('Decor/office_decor_plant_snake_01.png', 1, 2), 'nacl')
P('tempat_payung', nacl('Decor/office_decor_stand_umbrella_01.png', 1, 2), 'nacl')
P('tong_sampah_besar', nacl('Decor/office_decor_bin_waste_01.png', 1, 1), 'nacl')
P('proyektor', nacl('Electronics/office_electronics_projector_01.png', 1, 1), 'nacl')
P('printer_kecil', nacl('Electronics/office_electronics_printer_small_01.png', 1, 1), 'nacl')
P('jam_dinding_b', nacl('Electronics/office_electronics_clock_wall_01.png', 1, 1, 0.75), 'nacl')
P('rak_buku_kecil', rubber('bookshelf', 2, 3), 'rubber')
P('pintu_kayu', fit(rgba(RB+'objects/door_wood.png'), 1, 2), 'rubber')
P('jam_kecil', fit(rgba(RB+'objects/clock.png'), 1, 1), 'rubber')

# ------------------------------------------------------------ HIASAN KECIL (tanpa collision)
def small(src, px=16, dx=0, dy=0, smooth=True):
    im = src.crop(src.getbbox())
    k = px / max(im.width, im.height)
    im = im.resize((max(1, round(im.width*k)), max(1, round(im.height*k))), Image.LANCZOS if smooth else Image.NEAREST)
    a = np.array(im); a[..., 3] = np.where(a[..., 3] > 110, 255, 0); im = Image.fromarray(a)
    can = Image.new('RGBA', (T, T)); can.alpha_composite(im, ((T-im.width)//2 + dx, (T-im.height)//2 + dy))
    return can
SMALL = {}
def S(name, im): SMALL[name] = im
S('laptop', small(rgba(IM+'Props/Tech/laptop/laptop_front.png'), 20, smooth=False))
S('mug', small(rgba(IM+'Props/Desk_Items/coffee_mug/coffee_mug_front.png'), 12, 6, 2, smooth=False))
S('lampu_meja', small(rgba(IM+'Props/Desk_Items/desk_lamp/desk_lamp_front.png'), 24, -4, -2, smooth=False))
S('kertas', small(rgba(IM+'Props/Desk_Items/paper_stack/paper_stack_front.png'), 18, smooth=False))
S('kertas_lantai', small(rgba(NC+'Props/office_props_papers_stack_01.png'), 14, -5, 6))
S('stapler', small(rgba(NC+'Props/office_props_stapler_01.png'), 12, 6, 4))
S('kalkulator', small(rgba(NC+'Props/office_props_calculator_01.png'), 13, -5, 3))
S('tempat_pena', small(rgba(NC+'Props/office_props_pen_cup_01.png'), 13, 7, -1))
S('buku_catatan', small(rgba(NC+'Props/office_props_notebook_closed_01.png'), 14, -4, 2))
S('headphone', small(rgba(NC+'Props/office_props_headphones_01.png'), 14, 4, 0))
S('kaktus', small(rgba(NC+'Props/office_props_succulent_small_01.png'), 13, 7, -2))
S('foto', small(rgba(NC+'Props/office_props_frame_photo_blank_01.png'), 13, -7, -2))
S('organizer', small(rgba(NC+'Props/office_props_organizer_desk_01.png'), 15, 0, -2))
S('botol', small(rgba(NC+'Props/office_props_water_bottle_01.png'), 14, 8, -2))
S('papan_klip', small(rgba(NC+'Props/office_props_clipboard_blank_01.png'), 14, -3, 2))
S('kunci', small(rgba(NC+'Props/office_props_keys_set_01.png'), 10, 5, 6))
S('selotip', small(rgba(NC+'Props/office_props_tape_dispenser_01.png'), 12, -6, 4))
S('map', small(rgba(NC+'Props/office_props_folder_closed_01.png'), 14, 2, 3))
S('usb', small(rgba(NC+'Props/office_props_usb_drive_01.png'), 8, 7, 7))
S('laptop_tutup', small(rgba(NC+'Electronics/office_electronics_laptop_closed_01.png'), 18, 0, 1))
S('laptop_b', small(rgba(NC+'Electronics/office_electronics_laptop_open_off_01.png'), 18, 0, -1))
S('monitor', small(rgba(NC+'Electronics/office_electronics_monitor_single_off_01.png'), 20, 0, -3))
S('lampu_meja_b', small(rgba(NC+'Electronics/office_electronics_lamp_desk_01.png'), 18, -6, -3))
S('kertas_r', small(rgba(RB+'objects/laptop_open.png'), 16, 0, 0, smooth=False))
S('mug_r', small(rgba(RB+'objects/mug.png'), 10, -6, 4, smooth=False))
S('boks_kecil', small(rgba(NC+'Props/office_props_archive_box_01.png'), 18, 0, 4))
S('kertas_lantai_b', small(rgba(IM+'Props/Desk_Items/paper_stack/paper_stack_back.png'), 16, 6, 6, smooth=False))
S('sampah_kecil', small(rgba(NC+'Props/office_props_wastebasket_small_01.png'), 14, 6, 6))

# ================================================================== LAYOUT v2
ROOMS = [
    ('Gudang',        'karpet_rapat', (1, 6, 8, 14)),
    ('Toilet',        'ubin_putih',   (1, 17, 8, 21)),
    ('R. Arsip',      'kayu',         (1, 24, 8, 38)),
    ('Pantry',        'ubin_krem',    (10, 4, 20, 10)),
    ('R. Istirahat',  'kayu',         (22, 4, 31, 10)),
    ('R. Rapat',      'kayu_gelap',   (33, 2, 45, 10)),
    ('R. Manager',    'karpet_biru',  (47, 3, 53, 10)),
    ('R. Keuangan',   'karpet_abu',   (55, 2, 62, 12)),
    ('Koridor',       'karpet_rapat', (10, 13, 59, 30)),
    ('Area Kerja',    'karpet_biru',  (13, 16, 35, 26)),
    ('R. IT',         'ubin_putih',   (38, 19, 43, 26)),
    ('R. Fotokopi',   'ubin_terang',  (45, 19, 50, 26)),
    ('R. HR',         'kayu',         (52, 19, 55, 26)),
    ('Lorong Timur',  'karpet_abu',   (61, 15, 62, 30)),
    ('R. Serbaguna',  'ubin_krem',    (10, 32, 21, 38)),
    ('R. Server',     'ubin_putih',   (23, 33, 32, 38)),
    ('Lobby',         'ubin_terang',  (34, 32, 46, 38)),
    ('Resepsionis',   'kayu_gelap',   (48, 33, 62, 38)),
]
ZONES = [  # karpet / aksen lantai di atas lantai ruangan
    ('karpet_biru', (35, 3, 44, 9)), ('karpet_abu', (24, 6, 29, 8)), ('karpet_rapat', (48, 6, 52, 9)),
    ('karpet_biru', (37, 33, 43, 36)), ('karpet_rapat', (56, 35, 61, 38)), ('ubin_putih', (10, 4, 20, 5)),
    ('karpet_abu', (13, 16, 19, 19)), ('karpet_abu', (28, 16, 34, 19)), ('karpet_abu', (13, 22, 20, 25)),
    ('karpet_abu', (28, 21, 33, 25)), ('ubin_terang', (24, 20, 27, 23)), ('karpet_rapat', (20, 23, 25, 26)),
    ('karpet_biru', (11, 33, 17, 37)),
    ('ubin_terang', (10, 13, 12, 15)), ('ubin_terang', (57, 15, 59, 17)), ('ubin_terang', (10, 28, 12, 30)),
    ('ubin_terang', (57, 28, 59, 30)), ('karpet_abu', (2, 9, 7, 12)),
    ('karpet_abu', (13, 14, 53, 14)), ('karpet_abu', (11, 16, 11, 27)), ('karpet_abu', (13, 29, 56, 29)),
    ('karpet_abu', (58, 18, 58, 27)),
]
LABELS = {
    'Gudang': (4.5, 8), 'Toilet': (4.5, 20), 'R. Arsip': (4.5, 31), 'Pantry': (15.5, 9),
    'R. Istirahat': (26.5, 9.5), 'R. Rapat': (39, 8.5), 'R. Manager': (50, 10),
    'R. Keuangan': (58.5, 7), 'Area Kerja': (24.5, 19.5), 'R. IT': (40.5, 21),
    'R. Fotokopi': (47.5, 23), 'R. HR': (53.5, 23.5), 'R. Serbaguna': (16, 37.5),
    'R. Server': (27.5, 34), 'Lobby': (40.5, 37), 'Resepsionis': (55, 36.5), 'Lorong Timur': (61.5, 23),
}

# --- dinding
back(4, 0, 9); vert(0, 4, 39, 'L')
back(2, 9, 31); vert(9, 2, 39, 'L')
vert(21, 2, 11, 'R')
back(0, 32, 46); vert(32, 0, 11, 'L'); vert(46, 0, 11, 'R')
back(1, 47, 53)
back(0, 54, 63); vert(54, 0, 13, 'L'); vert(63, 0, 39, 'R')
back(11, 9, 54); back(13, 54, 63)
back(15, 0, 9); back(22, 0, 9)
back(17, 37, 56); front(27, 37, 56)
for c, sd in ((37, 'L'), (44, 'L'), (51, 'L'), (56, 'R')): vert(c, 17, 27, sd)
vert(60, 13, 31, 'L')
back(30, 9, 22); back(31, 23, 33); back(30, 34, 47); back(31, 48, 63)
for c in (22, 33, 47): vert(c, 30, 39, 'R')
front(39, 0, 63)

# --- bukaan / pintu
carve_rect(9, 7, 9, 8); carve_rect(9, 13, 9, 14); carve_rect(9, 18, 9, 19)
DOOR_A = [(9, 26), (9, 27)]; carve(DOOR_A)
carve_rect(9, 35, 9, 36)
for c in (21, 32, 46, 54): carve_rect(c, 6, c, 7)
for c0 in (15, 26, 39, 49): carve_rect(c0, 11, c0+1, 12)
for c0 in (57, 61): carve_rect(c0, 13, c0+1, 14)
carve_rect(37, 21, 37, 22); carve_rect(44, 22, 44, 23); carve_rect(51, 21, 51, 22); carve_rect(56, 23, 56, 24)
carve_rect(47, 27, 48, 27); carve_rect(53, 27, 54, 27)
DOOR_B = [(60, 21), (60, 22)]; carve(DOOR_B)
carve_rect(15, 30, 16, 31); carve_rect(27, 31, 28, 32); carve_rect(39, 30, 41, 31)
carve_rect(54, 31, 55, 32); carve_rect(61, 31, 62, 32)
for c in (22, 33, 47): carve_rect(c, 35, c, 36)

# ------------------------------------------------------------ varian cermin (v3)
for _n in ['meja_sudut', 'meja_proyek', 'meja_monitor', 'partisi', 'flipchart', 'meja_berdiri', 'meja_panel',
           'kursi_tamu', 'lampu_lantai', 'kabinet_rendah', 'meja_depan']:
    PROPS[_n + '_cermin'] = (PROPS[_n][0].transpose(Image.FLIP_LEFT_RIGHT), PROPS[_n][1])

PLACE = [
 # Gudang: tumpukan boks berserakan, jalan berkelok
 ('rak_buku', 1, 5), ('lemari_tinggi', 3, 5), ('tumpukan_boks', 6, 5), ('tumpukan_boks', 7, 6), ('boks_arsip', 5, 6),
 ('tumpukan_boks', 3, 9), ('tumpukan_boks', 4, 10), ('tumpukan_boks', 5, 9), ('boks_arsip', 2, 11), ('boks_arsip', 5, 11),
 ('tumpukan_boks', 1, 12), ('boks_arsip', 3, 14), ('boks_arsip', 4, 13), ('lemari_tinggi', 1, 8),
 # Toilet
 ('partisi', 1, 16), ('partisi', 3, 16), ('partisi_cermin', 5, 16), ('tanaman_lidah', 8, 16), ('tong_sampah', 1, 21),
 ('tempat_sampah_daurulang', 8, 21),
 # R. Arsip: rak zig-zag membentuk lorong miring
 ('lemari_arsip', 1, 23), ('lemari_arsip', 2, 23), ('lemari_kecil', 6, 23), ('lemari_kecil', 7, 23), ('penghancur_kertas', 8, 24),
 ('rak_buku', 3, 26), ('lemari_tinggi', 1, 29), ('rak_buku', 6, 29), ('rak_buku', 2, 31),
 ('meja_samping_kanan', 6, 33), ('kursi_hadap_kiri', 7, 33), ('tumpukan_boks', 2, 36), ('tumpukan_boks', 1, 37),
 ('boks_arsip', 5, 38), ('boks_arsip', 8, 38), ('boks_arsip', 4, 35),
 # Pantry: dapur L + meja bar di tengah
 ('kulkas', 10, 3), ('kabinet_rendah', 11, 3), ('kabinet_rendah', 13, 3), ('dispenser', 15, 3),
 ('tanaman_besar', 18, 3), ('tanaman', 20, 4), ('kabinet_rendah_cermin', 13, 6), ('kursi_bar', 12, 8), ('kursi_bar', 15, 8),
 ('kursi_bar', 12, 6), ('meja_kopi', 17, 8), ('kursi_bar', 19, 8), ('kursi_bar', 18, 9),
 ('tong_sampah', 10, 10), ('tempat_sampah_daurulang', 11, 10),
 # R. Istirahat: sofa bentuk U mengelilingi karpet
 ('sofa', 24, 4), ('tanaman', 22, 3), ('sofa', 23, 9), ('kursi_hadap_kiri', 28, 6), ('meja_kopi', 25, 7),
 ('palem', 31, 3), ('lampu_lantai', 30, 4), ('kursi_tamu', 29, 9), ('tanaman_lebar', 31, 9), ('kursi_tamu_cermin', 22, 5),
 # R. Rapat: meja panjang vertikal + meja diskusi kecil di sudut
 ('meja_rapat_tegak', 37, 3), ('kursi_rapat', 36, 3), ('kursi_rapat', 36, 5), ('kursi_rapat', 39, 4), ('kursi_rapat', 39, 6),
 ('kursi_rapat', 38, 7),
 ('meja_rapat', 41, 5), ('kursi_rapat', 41, 4), ('kursi_rapat', 44, 6), ('kursi_rapat', 42, 8), ('kursi_rapat', 40, 7),
 ('tanaman_tinggi', 33, 1), ('tanaman_tinggi', 45, 1), ('flipchart_cermin', 34, 8), ('kabinet_rendah', 44, 9),
 ('tanaman_kecil', 33, 10),
 # R. Manager: meja L + sudut tamu
 ('rak_buku', 47, 2), ('lemari_tinggi', 53, 2), ('meja_sudut', 50, 4), ('kursi_kerja', 52, 5), ('tanaman_kecil', 52, 3),
 ('sofa', 51, 8), ('meja_kopi', 51, 7), ('tanaman_lebar', 47, 9), ('kursi_tamu', 48, 6),
 # R. Keuangan: meja berselang-seling
 ('lemari_arsip', 55, 1), ('lemari_arsip', 56, 1), ('lemari_tinggi', 61, 1), ('lemari_tinggi', 62, 1),
 ('meja_kecil', 56, 3), ('kursi_kerja', 57, 5), ('meja_kecil', 59, 5), ('kursi_kerja', 60, 7),
 ('meja_kecil', 56, 8), ('kursi_kerja', 57, 10), ('meja_kecil', 60, 9), ('kursi_kerja', 61, 11),
 ('lemari_kecil', 62, 6), ('tanaman', 55, 10),
 # Koridor
 ('tanaman_tinggi', 10, 12), ('tanaman_kecil', 11, 13),
 ('meja_monitor', 22, 12), ('dispenser', 33, 12), ('tong_sampah_besar', 34, 13),
 ('kursi_tamu', 44, 13), ('kursi_tamu_cermin', 46, 13), ('tanaman_lebar', 53, 12), ('pohon_indoor', 59, 15),
 ('tanaman', 59, 29), ('tanaman', 10, 29), ('tempat_sampah_daurulang', 10, 24), ('kursi_tamu', 30, 30),
 ('kursi_tamu_cermin', 32, 30), ('tanaman_lidah', 23, 29), ('tong_sampah', 48, 30), ('lemari_kecil', 36, 25),
 ('tanaman_kecil', 57, 27), ('boks_arsip', 12, 27),
 # Area Kerja: pod zig-zag, meja hadap samping, pulau tanaman
 ('meja_monitor', 14, 16), ('meja_monitor_cermin', 16, 17), ('kursi_kerja', 14, 18), ('kursi_kerja', 17, 19), ('partisi', 18, 16),
 ('meja_samping_kanan', 21, 16), ('kursi_kerja', 20, 17), ('meja_samping_kiri', 23, 16), ('kursi_kerja', 24, 17),
 ('tanaman_besar', 26, 17),
 ('meja_monitor', 29, 16), ('meja_monitor_cermin', 32, 17), ('kursi_kerja', 29, 18), ('kursi_kerja', 32, 19), ('tanaman', 35, 16),
 ('meja_berdiri', 25, 21), ('printer', 27, 22),
 ('meja_sudut', 14, 22), ('meja_sudut_cermin', 17, 23), ('kursi_kerja', 16, 22), ('kursi_kerja', 19, 24),
 ('meja_belakang', 21, 24), ('meja_panel_cermin', 23, 25), ('kursi_kerja', 21, 23), ('kursi_kerja', 23, 24),
 ('meja_belakang', 29, 22), ('meja_belakang', 31, 23), ('kursi_kerja', 29, 21), ('kursi_kerja', 31, 22),
 ('lemari_arsip', 34, 24), ('tanaman', 33, 20), ('laci_dorong', 19, 20), ('tanaman_lidah', 13, 25), ('lemari_kecil', 35, 22),
 ('tanaman_lebar', 27, 25),
 # R. IT: rak server diagonal
 ('rak_server', 38, 18), ('rak_server', 39, 18), ('rak_server', 40, 18), ('ups', 42, 19), ('panel_listrik', 43, 19),
 ('rak_server', 40, 21), ('rak_server', 41, 22), ('rak_server', 42, 23), ('meja_kecil', 38, 25), ('kursi_kerja', 40, 25),
 # R. Fotokopi
 ('mesin_fotokopi', 45, 18), ('printer_kecil', 47, 19), ('mesin_fotokopi', 49, 18), ('tumpukan_boks', 45, 24),
 ('boks_arsip', 46, 25), ('boks_arsip', 45, 26), ('meja_kecil', 48, 23), ('penghancur_kertas', 50, 25),
 # R. HR
 ('lemari_arsip', 52, 18), ('lemari_arsip', 53, 18), ('tanaman_lidah', 55, 18), ('meja_depan', 53, 21),
 ('kursi_kerja', 53, 20), ('kursi_tamu', 53, 23), ('kursi_tamu_cermin', 54, 24), ('lemari_kecil', 55, 25),
 # Lorong timur: boks zig-zag
 ('tumpukan_boks', 62, 16), ('tumpukan_boks', 61, 18), ('tumpukan_boks', 62, 24), ('lemari_kecil', 61, 27),
 # R. Serbaguna: meja proyek berselang
 ('flipchart', 20, 31), ('meja_proyek', 12, 33), ('meja_proyek_cermin', 15, 34), ('kursi_kerja', 12, 35),
 ('kursi_kerja', 14, 33), ('kursi_kerja', 17, 36), ('meja_berdiri_cermin', 18, 33), ('tumpukan_boks', 21, 37),
 ('tumpukan_boks', 20, 36), ('rak_buku', 10, 32), ('tumpukan_boks', 10, 37),
 # R. Server: rak diagonal membentuk lorong V
 ('rak_server', 23, 32), ('rak_server', 24, 32), ('rak_server', 25, 32), ('rak_server', 26, 32),
 ('rak_server', 29, 32), ('rak_server', 30, 32), ('rak_server', 31, 32), ('rak_server', 32, 32),
 ('rak_server', 24, 34), ('rak_server', 25, 35), ('rak_server', 26, 36),
 ('rak_server', 31, 34), ('rak_server', 30, 35), ('rak_server', 29, 36), ('ups', 23, 38), ('ups', 32, 38),
 # Lobby: asimetris
 ('palem', 34, 31), ('tanaman_besar', 36, 31), ('tanaman_lebar', 44, 31), ('palem', 46, 31),
 ('sofa', 35, 34), ('kursi_tamu', 44, 33), ('kursi_tamu', 45, 35),
 ('tanaman_kecil', 43, 33),
 ('tempat_payung', 38, 37), ('tempat_payung', 42, 37), ('lampu_lantai', 34, 37), ('pohon_indoor', 46, 37),
 # Resepsionis
 ('meja_resepsionis', 51, 34), ('kursi_kerja', 52, 33), ('lemari_tinggi', 49, 32), 
 ('sofa', 57, 37), ('kursi_tamu', 56, 35), ('kursi_tamu_cermin', 61, 36), ('meja_kopi', 58, 35), ('palem', 62, 33),
 ('tanaman_lebar', 48, 37), ('tempat_payung', 50, 37),
]
SMALL_PLACE_FIXED = [
 ('lampu_meja', 6, 33), ('map', 6, 34), ('laptop', 37, 4), ('laptop_b', 38, 5), ('kertas', 37, 6), ('botol', 38, 3),
 ('papan_klip', 42, 6), ('laptop_tutup', 43, 5), ('mug', 41, 6),
 ('lampu_meja', 50, 4), ('laptop', 51, 4), ('foto', 50, 5), ('mug', 51, 7),
 ('monitor', 52, 34), ('kertas', 53, 34), ('mug', 51, 34), ('kertas', 58, 35), ('buku_catatan', 59, 35),
 ('mug', 11, 4), ('botol', 13, 4), ('mug_r', 14, 4), ('mug', 13, 6), ('botol', 14, 7), ('laptop_tutup', 17, 8),
 ('mug', 25, 7), ('buku_catatan', 26, 7), ('mug', 23, 13), ('kertas', 22, 13),
 ('laptop_b', 38, 25), ('usb', 39, 25), ('kertas', 48, 23), ('kertas', 49, 23), ('map', 53, 21), ('foto', 54, 21),
 ('laptop', 12, 33), ('kertas', 13, 33), ('papan_klip', 15, 34), ('laptop_tutup', 18, 33), ('mug', 19, 33),
 ('laptop', 25, 21), ('mug', 26, 21),
]
DESK_ITEMS = {  # prop meja -> sel permukaan relatif
 'meja_monitor': [(1, 1)], 'meja_monitor_cermin': [(0, 1)], 'meja_belakang': [(0, 0), (1, 0)],
 'meja_sudut': [(0, 0), (1, 0)], 'meja_sudut_cermin': [(0, 0), (1, 0)], 'meja_panel_cermin': [(0, 0), (1, 0)],
 'meja_kecil': [(0, 0), (1, 0)], 'meja_samping_kanan': [(0, 0), (0, 1)], 'meja_samping_kiri': [(0, 0), (0, 1)],
 'meja_depan': [(0, 0), (1, 0)],
}
ITEM_POOL = ['mug', 'kertas', 'tempat_pena', 'headphone', 'kaktus', 'foto', 'organizer', 'botol', 'laptop', 'laptop_b',
             'buku_catatan', 'kalkulator', 'stapler', 'papan_klip', 'map', 'mug_r', 'lampu_meja_b', 'selotip', 'kunci']
FLOOR_POOL = ['kertas_lantai', 'kertas_lantai_b', 'kertas_lantai', 'sampah_kecil', 'kertas_lantai']
DOOR_DECOR = []

WALL_PLACE = [
 ('jam_dinding', 17, 3), ('jendela', 24, 3), ('jendela', 28, 3), ('lukisan', 26, 3),
 ('layar_proyektor', 38, 1), ('whiteboard', 43, 1), ('jam_dinding', 35, 1), ('jendela', 41, 1),
 ('lukisan', 49, 2), ('jendela', 51, 2), ('jendela', 58, 1), ('jendela', 59, 1),
 ('lukisan', 19, 12), ('lukisan', 30, 12), ('lukisan', 42, 12), ('kamera_cctv', 12, 12), ('kamera_cctv', 51, 12),
 ('jam_dinding', 37, 12), ('kamera_cctv', 42, 18), ('jam_kecil', 47, 18), ('lukisan', 54, 18),
 ('whiteboard', 12, 31), ('whiteboard', 13, 31), ('jam_dinding', 38, 31),
 ('lukisan', 42, 31), ('kamera_cctv', 45, 31), ('lukisan', 57, 32), ('jam_dinding', 59, 32), ('kamera_cctv', 56, 32),
 ('jam_kecil', 7, 16), ('lukisan', 5, 23), ]


# ================================================================== NODES v2
def cpx(c, r): return (c*T + 16, r*T + 16)
TASKS = [
 ('pc_koridor', 'PC Koridor', 'excel', (23*T, 14*T+16), {}),
 ('pc_barat', 'PC Workspace Barat', 'slides', (16*T, 18*T+16), {}),
 ('pc_tengah', 'PC Workspace Tengah', 'email', (23*T, 21*T+16), {}),
 ('pc_fotokopi', 'PC Fotokopi', 'copy', (46*T, 20*T+16), {}),
 ('arsip', 'Arsip Dokumen', 'archive', (6*T, 35*T+16), {'accent': 'Color(1, 0.6, 0.3, 1)'}),
 ('listrik', 'Panel Listrik', 'simon', (43*T+16, 20*T+16), {'accent': 'Color(0.4, 0.85, 1, 1)'}),
 ('server', 'Server (Co-op)', 'server', (28*T, 37*T+16), {'requires_two': 'true', 'accent': 'Color(0.75, 0.55, 1, 1)'}),
]
HIDES = [cpx(*x) for x in [(2, 10), (13, 8), (22, 9), (35, 9), (53, 7), (59, 7), (2, 19), (5, 37), (5, 27),
                           (19, 18), (15, 24), (28, 23), (34, 20), (38, 23), (46, 23), (52, 25), (62, 20),
                           (19, 37), (31, 37), (50, 35), (34, 14), (36, 37)]]
SPAWNS = {
 'PlayerSpawn1': cpx(39, 34), 'PlayerSpawn2': cpx(41, 34),
 'EnemySpawn1': cpx(4, 8), 'EnemySpawn2': cpx(58, 11), 'EnemySpawn3': cpx(5, 30), 'EnemySpawn4': cpx(27, 34),
 'EnemySpawn5': cpx(61, 23), 'EnemySpawn6': cpx(38, 9), 'EnemySpawn7': cpx(13, 37), 'EnemySpawn8': cpx(58, 34),
 'Patrol1': cpx(11, 14), 'Patrol2': cpx(35, 14), 'Patrol3': cpx(58, 16), 'Patrol4': cpx(58, 29),
 'Patrol5': cpx(35, 29), 'Patrol6': cpx(11, 29), 'Patrol7': cpx(11, 21), 'Patrol8': cpx(58, 22),
 'Revive1': cpx(5, 7), 'Revive2': cpx(59, 9), 'Revive3': cpx(13, 38), 'Revive4': cpx(60, 37),
 'Revive5': cpx(20, 20), 'Revive6': cpx(43, 25), 'Revive7': cpx(41, 9), 'Revive8': cpx(4, 18),
}
LIGHTS = [
 ((4.5, 9), 0.6, 1.6), ((15.5, 7), 0.7, 1.8), ((26.5, 7), 0.8, 2.0), ((39, 6), 0.8, 2.2),
 ((50, 6), 0.6, 1.6), ((58.5, 7), 0.7, 1.8), ((4.5, 19), 0.5, 1.4), ((4.5, 30), 0.6, 1.6), ((4.5, 35), 0.6, 1.4),
 ((20, 14), 0.9, 2.2), ((46, 14), 0.9, 2.2), ((19, 20), 0.8, 2.0), ((30, 20), 0.8, 2.0), ((24, 25), 0.6, 1.6),
 ((40.5, 22), 0.7, 1.8), ((47.5, 22), 0.7, 1.8), ((53.5, 22), 0.6, 1.5), ((22, 28.5), 0.8, 2.0), ((50, 28.5), 0.7, 1.8),
 ((15.5, 35), 0.7, 1.8), ((28, 35.5), 0.7, 1.8), ((40.5, 35), 0.9, 2.2), ((55, 35.5), 0.8, 2.0), ((61.5, 22), 0.4, 1.2),
]
EXIT_POS = (40*T+16, 38*T+16)
CAGE_POS = cpx(4, 8)
REVIVE_POS = cpx(20, 20)
PATROL_LOOP = ['Patrol1', 'Patrol2', 'Patrol3', 'Patrol8', 'Patrol4', 'Patrol5', 'Patrol6', 'Patrol7']
# ================================================================== BUILD
def build():
    os.makedirs(os.path.join(OUT, TDIR), exist_ok=True)
    # ---- walls atlas
    wall_imgs, wall_key, wall_cells = [], {}, {}
    for r in range(H):
        for c in range(W):
            if not is_wall(c, r): continue
            im = wall_tile(c, r)
            k = im.tobytes()
            if k not in wall_key:
                wall_key[k] = len(wall_imgs); wall_imgs.append(im)
            wall_cells[(c, r)] = wall_key[k]
    WCOLS = 8
    wrows = (len(wall_imgs) + WCOLS - 1)//WCOLS
    watlas = np.zeros((wrows*T, WCOLS*T, 4), np.uint8)
    for i, im in enumerate(wall_imgs):
        watlas[(i//WCOLS)*T:(i//WCOLS)*T+T, (i % WCOLS)*T:(i % WCOLS)*T+T] = im
    Image.fromarray(watlas).save(os.path.join(OUT, TDIR, 'dinding_lembur.png'))
    wall_coord = lambda i: (i % WCOLS, i//WCOLS)
    # ---- floors atlas
    fat = Image.new('RGBA', (len(FLOOR_ORDER)*T, T))
    for i, n in enumerate(FLOOR_ORDER): fat.paste(FLOORS[n][0], (i*T, 0))
    fat.save(os.path.join(OUT, TDIR, 'lantai_lembur.png'))
    # ---- props atlas (shelf pack, 16 kolom)
    PCOLS = 16
    used_names = []
    for n, _, _ in PLACE + WALL_PLACE:
        if n not in used_names: used_names.append(n)
    for n in PROPS:
        if n not in used_names: used_names.append(n)   # sisanya tetap masuk atlas, bisa dipakai nanti
    for n, im in SMALL.items():
        PROPS['kecil_' + n] = (im, 'kecil'); WALL_MOUNTED.add('kecil_' + n); used_names.append('kecil_' + n)
    x = y = rowh = 0; prop_pos = {}
    for n in used_names:
        im = PROPS[n][0]; w, h = im.width//T, im.height//T
        if x + w > PCOLS: x = 0; y += rowh; rowh = 0
        prop_pos[n] = (x, y); x += w; rowh = max(rowh, h)
    ph = y + rowh
    pat = Image.new('RGBA', (PCOLS*T, ph*T))
    for n in used_names: pat.alpha_composite(PROPS[n][0], (prop_pos[n][0]*T, prop_pos[n][1]*T))
    pat.save(os.path.join(OUT, TDIR, 'props_lembur.png'))
    parr = np.array(pat)
    prop_tiles = {}  # (ax,ay) -> collision bool
    for n in used_names:
        px, py = prop_pos[n]; im = PROPS[n][0]
        for dy in range(im.height//T):
            for dx in range(im.width//T):
                cell = parr[(py+dy)*T:(py+dy)*T+T, (px+dx)*T:(px+dx)*T+T]
                if cell[..., 3].max() > 0:
                    prop_tiles[(px+dx, py+dy)] = n not in WALL_MOUNTED
    # ---- grids
    floor_grid = [[None]*W for _ in range(H)]
    for name, fl, (c0, r0, c1, r1) in ROOMS:
        for r in range(r0, r1+1):
            for c in range(c0, c1+1):
                if not is_wall(c, r): floor_grid[r][c] = fl
    for fl, (c0, r0, c1, r1) in ZONES:
        for r in range(r0, r1+1):
            for c in range(c0, c1+1):
                if floor_grid[r][c]: floor_grid[r][c] = fl
    roomcell = set((c, r) for _, _, (c0, r0, c1, r1) in ROOMS for r in range(r0, r1+1) for c in range(c0, c1+1))
    # dinding vertikal L/R: lantai di bawahnya = ruangan di sisi yang terbuka
    for r in range(H):
        for c in range(W):
            if floor_grid[r][c] or rowtype[r][c]: continue
            if strip[r][c] == 'L' and c+1 < W and floor_grid[r][c+1]: floor_grid[r][c] = floor_grid[r][c+1]
            if strip[r][c] == 'R' and c-1 >= 0 and floor_grid[r][c-1]: floor_grid[r][c] = floor_grid[r][c-1]
    # sisanya: ambil lantai terdekat
    from collections import deque
    q = deque((c, r) for r in range(H) for c in range(W) if floor_grid[r][c])
    while q:
        c, r = q.popleft()
        for dc, dr in ((0, -1), (-1, 0), (1, 0), (0, 1)):
            cc, rr = c+dc, r+dr
            if 0 <= cc < W and 0 <= rr < H and floor_grid[rr][cc] is None:
                floor_grid[rr][cc] = floor_grid[r][c]; q.append((cc, rr))
    for r in range(H):
        for c in range(W):
            if not is_wall(c, r) and (c, r) not in roomcell and (c, r) not in CARVED: floor_grid[r][c] = None
    for (c, r) in sorted(CARVED, key=lambda x: (x[1], x[0])):
        horiz = any((c, rr) in CARVED for rr in (r-1, r+1)) and not any((cc, r) in CARVED for cc in (c-1, c+1))
        if horiz:  # bukaan di dinding vertikal -> ambil lantai kiri
            for cc in range(c-1, -1, -1):
                if (cc, r) in roomcell and not is_wall(cc, r): floor_grid[r][c] = floor_grid[r][cc]; break
        else:      # bukaan di dinding horizontal -> ambil lantai atas
            for rr in range(r-1, -1, -1):
                if (c, rr) in roomcell and not is_wall(c, rr): floor_grid[r][c] = floor_grid[rr][c]; break
    props_grid, dekor_grid = {}, {}
    for n, c0, r0 in PLACE + WALL_PLACE:
        px, py = prop_pos[n]; im = PROPS[n][0]
        tgt = dekor_grid if n in WALL_MOUNTED else props_grid
        for dy in range(im.height//T):
            for dx in range(im.width//T):
                if (px+dx, py+dy) in prop_tiles:
                    key = (c0+dx, r0+dy)
                    if key in tgt: print('OVERLAP', n, key, file=sys.stderr)
                    tgt[key] = (px+dx, py+dy, n)
    import random
    rnd = random.Random(11)
    sp = list(SMALL_PLACE_FIXED); taken = set((c, r) for _, c, r in sp)
    for n, c0, r0 in PLACE:
        for (dx, dy) in DESK_ITEMS.get(n, []):
            cell = (c0+dx, r0+dy)
            if cell in taken or rnd.random() < 0.25: continue
            sp.append((rnd.choice(ITEM_POOL), *cell)); taken.add(cell)
    task_cells = set((x//T, y//T) for *_a, (x, y), _e in TASKS) | set((x//T, y//T) for x, y in HIDES)
    free = [(c, r) for r in range(H) for c in range(W) if floor_grid[r][c] and not is_wall(c, r)
            and (c, r) not in props_grid and (c, r) not in taken and (c, r) not in task_cells]
    rnd.shuffle(free)
    for (c, r) in free[:70]:
        sp.append((rnd.choice(FLOOR_POOL), c, r)); taken.add((c, r))
    globals()['SMALL_PLACE'] = sp
    small_grid = {}
    for n, c0, r0 in SMALL_PLACE:
        px, py = prop_pos['kecil_' + n]
        if (c0, r0) in small_grid: print('OVERLAP kecil', n, (c0, r0), file=sys.stderr)
        small_grid[(c0, r0)] = (px, py, n)
    G = dict(small=small_grid, walls=wall_cells, wall_coord=wall_coord, wall_imgs=wall_imgs, floor=floor_grid,
             props=props_grid, dekor=dekor_grid, prop_tiles=prop_tiles, pat=pat, fat=fat,
             watlas=Image.fromarray(watlas), used_names=used_names, prop_pos=prop_pos)
    return G

def check(G):
    from collections import deque
    walk = lambda c, r: (0 <= c < W and 0 <= r < H and G['floor'][r][c] and (c, r) not in G['walls']
                         and (c, r) not in G['props'])
    probs = []
    for doors_locked in (True, False):
        blocked = set(DOOR_A + DOOR_B) if doors_locked else set()
        start = (40, 35); seen = {start}; q = deque([start])
        while q:
            c, r = q.popleft()
            for dc, dr in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                n = (c+dc, r+dr)
                if n not in seen and walk(*n) and n not in blocked: seen.add(n); q.append(n)
        for name, fl, (c0, r0, c1, r1) in ROOMS:
            cells = [(c, r) for r in range(r0, r1+1) for c in range(c0, c1+1) if walk(c, r)]
            got = sum(1 for x in cells if x in seen)
            if got < len(cells): probs.append(f'locked={doors_locked} {name}: {[x for x in cells if x not in seen]} tak terjangkau')
        def near(px, py, rad):
            return any(((c*T+16-px)**2 + (r*T+16-py)**2) ** .5 <= rad for (c, r) in seen)
        for tid, *_r, pos, _e in [(t[0], t[3], t[4]) for t in TASKS]:
            pass
        for t in TASKS:
            if not near(*t[3], 50): probs.append(f'locked={doors_locked} task {t[0]} jauh dari lantai terjangkau')
        for i, h in enumerate(HIDES):
            if not near(*h, 30): probs.append(f'locked={doors_locked} hide {i+1} tak terjangkau')
        for k, p in SPAWNS.items():
            c, r = p[0]//T, p[1]//T
            if (c, r) not in seen: probs.append(f'locked={doors_locked} {k} di cell tak terjangkau {(c, r)}')
    return probs

# ================================================================== WRITE
def opaque_poly(im):
    a = im[..., 3] > 0
    if not a.any(): return None
    ys, xs = np.where(a)
    x0, x1, y0, y1 = xs.min(), xs.max()+1, ys.min(), ys.max()+1
    return f'PackedVector2Array({x0-16}, {y0-16}, {x1-16}, {y0-16}, {x1-16}, {y1-16}, {x0-16}, {y1-16})'

def write_tres(G):
    L = ['[gd_resource type="TileSet" format=3]', '',
         f'[ext_resource type="Texture2D" path="res://{TDIR}/dinding_lembur.png" id="1_dinding"]',
         f'[ext_resource type="Texture2D" path="res://{TDIR}/lantai_lembur.png" id="2_lantai"]',
         f'[ext_resource type="Texture2D" path="res://{TDIR}/props_lembur.png" id="3_props"]', '']
    # walls
    L += ['[sub_resource type="TileSetAtlasSource" id="Src_Dinding"]', 'resource_name = "Dinding (Imersa)"',
          'texture = ExtResource("1_dinding")', 'texture_region_size = Vector2i(32, 32)']
    for i, im in enumerate(G['wall_imgs']):
        cx, cy = G['wall_coord'](i)
        L.append(f'{cx}:{cy}/0 = 0')
        p = opaque_poly(im)
        if p: L.append(f'{cx}:{cy}/0/physics_layer_0/polygon_0/points = {p}')
    L += ['', '[sub_resource type="TileSetAtlasSource" id="Src_Lantai"]', 'resource_name = "Lantai"',
          'texture = ExtResource("2_lantai")', 'texture_region_size = Vector2i(32, 32)']
    for i in range(len(FLOOR_ORDER)): L.append(f'{i}:0/0 = 0')
    L += ['', '[sub_resource type="TileSetAtlasSource" id="Src_Props"]', 'resource_name = "Props / Furnitur"',
          'texture = ExtResource("3_props")', 'texture_region_size = Vector2i(32, 32)']
    for (ax, ay), col in sorted(G['prop_tiles'].items(), key=lambda k: (k[0][1], k[0][0])):
        L.append(f'{ax}:{ay}/0 = 0')
        if col: L.append(f'{ax}:{ay}/0/physics_layer_0/polygon_0/points = PackedVector2Array(-16, -16, 16, -16, 16, 16, -16, 16)')
    L += ['', '[resource]', 'resource_name = "TileSet Kantor Lembur"', 'tile_size = Vector2i(32, 32)',
          'physics_layer_0/collision_layer = 1', 'physics_layer_0/collision_mask = 0',
          'sources/0 = SubResource("Src_Dinding")', 'sources/1 = SubResource("Src_Lantai")',
          'sources/2 = SubResource("Src_Props")', '']
    open(os.path.join(OUT, TDIR, 'tileset_lembur.tres'), 'w').write('\n'.join(L))

def tmdata(cells):  # cells: list of (x,y,src,ax,ay)
    b = bytearray(b'\x00\x00')
    for x, y, s, ax, ay in sorted(cells, key=lambda t: (t[1], t[0])):
        b += struct.pack('<hhHHHH', x, y, s, ax, ay, 0)
    return base64.b64encode(bytes(b)).decode()

def write_tscn(G):
    floor_cells = [(c, r, 1, FLOOR_ORDER.index(G['floor'][r][c]), 0) for r in range(H) for c in range(W) if G['floor'][r][c]]
    wall_cells = [(c, r, 0, *G['wall_coord'](i)) for (c, r), i in G['walls'].items()]
    prop_cells = [(c, r, 2, ax, ay) for (c, r), (ax, ay, n) in G['props'].items()]
    dek_cells = [(c, r, 2, ax, ay) for (c, r), (ax, ay, n) in G['dekor'].items()]
    kecil_cells = [(c, r, 2, ax, ay) for (c, r), (ax, ay, n) in G['small'].items()]
    S = []
    a = S.append
    a('[gd_scene format=4]'); a('')
    exts = [('Script', 'res://scripts/level_1.gd', 's_level'), ('TileSet', f'res://{TDIR}/tileset_lembur.tres', 't_set'),
            ('Texture2D', 'res://assets/sprites/light_soft.png', 'tx_light'),
            ('PackedScene', 'res://scenes/task_station.tscn', 'ps_task'), ('Script', 'res://scripts/task_station.gd', 's_task'),
            ('PackedScene', 'res://scenes/hiding_spot.tscn', 'ps_hide'), ('Script', 'res://scripts/hiding_spot.gd', 's_hide'),
            ('PackedScene', 'res://scenes/locked_door.tscn', 'ps_door'), ('Script', 'res://scripts/locked_door.gd', 's_door'),
            ('PackedScene', 'res://scenes/exit_door.tscn', 'ps_exit'), ('Script', 'res://scripts/exit_door.gd', 's_exit'),
            ('PackedScene', 'res://scenes/cage.tscn', 'ps_cage'), ('Script', 'res://scripts/cage.gd', 's_cage'),
            ('PackedScene', 'res://scenes/revive_item.tscn', 'ps_rev'), ('Script', 'res://scripts/revive_item.gd', 's_rev'),
            ('PackedScene', 'res://scenes/enemy.tscn', 'ps_enemy'), ('Script', 'res://scripts/enemy.gd', 's_enemy'),
            ('SpriteFrames', 'res://assets/characters/office_worker/office_worker.tres', 'sf_worker'),
            ('PackedScene', 'res://scenes/hud.tscn', 'ps_hud'), ('Script', 'res://scripts/hud.gd', 's_hud')]
    for t, p, i in exts: a(f'[ext_resource type="{t}" path="{p}" id="{i}"]')
    a(''); a('[sub_resource type="CircleShape2D" id="CircleShape2D_enemy"]'); a('radius = 12.0'); a('')
    a('[node name="Level1" type="Node2D"]'); a('script = ExtResource("s_level")'); a('')
    a('[node name="CanvasModulate" type="CanvasModulate" parent="."]'); a('color = Color(0.26, 0.26, 0.34, 1)'); a('')
    for name, z, cells in (('Floor', -10, floor_cells), ('Walls', -5, wall_cells), ('DekorDinding', -4, dek_cells), ('Props', 5, prop_cells), ('DekorKecil', 6, kecil_cells)):
        a(f'[node name="{name}" type="TileMapLayer" parent="."]'); a(f'z_index = {z}')
        a(f'tile_map_data = PackedByteArray("{tmdata(cells)}")'); a('tile_set = ExtResource("t_set")'); a('')
    a('[node name="Labels" type="Node2D" parent="."]'); a('')
    for i, (n, (lc, lr)) in enumerate(LABELS.items()):
        x, y = lc*T, lr*T
        a(f'[node name="Label_{i+1}" type="Label" parent="Labels"]'); a('z_index = 7')
        a(f'offset_left = {x-60:.1f}'); a(f'offset_top = {y-12:.1f}'); a(f'offset_right = {x+60:.1f}'); a(f'offset_bottom = {y+12:.1f}')
        a('theme_override_colors/font_color = Color(1, 1, 1, 0.4)'); a('theme_override_font_sizes/font_size = 13')
        a(f'text = "{n}"'); a('horizontal_alignment = 1'); a('')
    a('[node name="Lights" type="Node2D" parent="."]'); a('')
    for i, ((lc, lr), e, s) in enumerate(LIGHTS):
        a(f'[node name="Light_{i+1}" type="PointLight2D" parent="Lights"]'); a(f'position = Vector2({lc*T+16:.0f}, {lr*T+16:.0f})')
        a('color = Color(1, 0.88, 0.65, 1)'); a(f'energy = {e}'); a('texture = ExtResource("tx_light")'); a(f'texture_scale = {s}'); a('')
    a('[node name="Spawns" type="Node2D" parent="."]'); a('')
    for k, (x, y) in SPAWNS.items():
        a(f'[node name="{k}" type="Marker2D" parent="Spawns"]'); a(f'position = Vector2({x}, {y})'); a('')
    a('[node name="Tasks" type="Node2D" parent="."]'); a('')
    for tid, title, gt, (x, y), ex in TASKS:
        a(f'[node name="Task_{tid}" parent="Tasks" instance=ExtResource("ps_task")]'); a(f'position = Vector2({x}, {y})')
        a('script = ExtResource("s_task")'); a(f'task_id = &"{tid}"'); a(f'title = "{title}"'); a(f'game_type = &"{gt}"')
        for k, v in ex.items(): a(f'{k} = {v}')
        a('')
    a('[node name="HidingSpots" type="Node2D" parent="."]'); a('')
    for i, (x, y) in enumerate(HIDES):
        a(f'[node name="Hide_{i+1}" parent="HidingSpots" instance=ExtResource("ps_hide")]'); a(f'position = Vector2({x}, {y})')
        a('script = ExtResource("s_hide")'); a(f'spot_id = &"hide_{i+1}"'); a('')
    a('[node name="Doors" type="Node2D" parent="."]'); a('')
    for did, cells in (('A', DOOR_A), ('B', DOOR_B)):
        c, r = cells[0]
        a(f'[node name="Door{did}" parent="Doors" instance=ExtResource("ps_door")]'); a(f'position = Vector2({c*T+16}, {(r+1)*T})')
        a('script = ExtResource("s_door")'); a(f'door_id = "{did}"')
        a('door_cells = Array[Vector2i]([' + ', '.join(f'Vector2i({x}, {y})' for x, y in cells) + '])'); a('')
    a('[node name="ExitDoor" parent="." instance=ExtResource("ps_exit")]'); a(f'position = Vector2{EXIT_POS}'); a('script = ExtResource("s_exit")'); a('')
    a('[node name="Cage" parent="." instance=ExtResource("ps_cage")]'); a(f'position = Vector2{CAGE_POS}'); a('script = ExtResource("s_cage")'); a('')
    a('[node name="ReviveItem" parent="." instance=ExtResource("ps_rev")]'); a(f'position = Vector2{REVIVE_POS}'); a('script = ExtResource("s_rev")'); a('')
    a('[node name="Players" type="Node2D" parent="."]'); a('')
    ex = SPAWNS['EnemySpawn1']
    a('[node name="Enemy" type="CharacterBody2D" parent="." instance=ExtResource("ps_enemy")]'); a('z_index = 10')
    a(f'position = Vector2({ex[0]}, {ex[1]})'); a('collision_layer = 3'); a('script = ExtResource("s_enemy")'); a('')
    a('[node name="CollisionShape2D" type="CollisionShape2D" parent="Enemy"]'); a('shape = SubResource("CircleShape2D_enemy")'); a('')
    a('[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="Enemy"]'); a('position = Vector2(0, -4)')
    a('sprite_frames = ExtResource("sf_worker")'); a('animation = &"idle_down"'); a('autoplay = "idle_down"'); a('')
    a('[node name="StateLabel" type="Label" parent="Enemy"]'); a('offset_left = -10.0'); a('offset_top = -38.0')
    a('offset_right = 10.0'); a('offset_bottom = -22.0'); a('text = "?"'); a('horizontal_alignment = 1'); a('')
    a('[node name="Glow" type="PointLight2D" parent="Enemy"]'); a('color = Color(1, 0.25, 0.25, 1)'); a('energy = 0.55')
    a('texture = ExtResource("tx_light")'); a('texture_scale = 0.7'); a('')
    a('[node name="HUD" parent="." instance=ExtResource("ps_hud")]'); a('script = ExtResource("s_hud")'); a('')
    open(os.path.join(OUT, 'scenes', 'level_1.tscn'), 'w').write('\n'.join(S))

def preview(G, path, markers=True, scale=1):
    img = Image.new('RGBA', (W*T, H*T), (12, 12, 20, 255))
    fat, wat, pat = G['fat'], G['watlas'], G['pat']
    for r in range(H):
        for c in range(W):
            f = G['floor'][r][c]
            if f: i = FLOOR_ORDER.index(f); img.alpha_composite(fat.crop((i*T, 0, i*T+T, T)), (c*T, r*T))
    for (c, r), i in G['walls'].items():
        ax, ay = G['wall_coord'](i); img.alpha_composite(wat.crop((ax*T, ay*T, ax*T+T, ay*T+T)), (c*T, r*T))
    for grid in (G['dekor'], G['props'], G['small']):
        for (c, r), (ax, ay, n) in grid.items():
            img.alpha_composite(pat.crop((ax*T, ay*T, ax*T+T, ay*T+T)), (c*T, r*T))
    if markers:
        d = ImageDraw.Draw(img)
        for n, (lc, lr) in LABELS.items():
            d.text((lc*T-len(n)*3, lr*T-5), n, fill=(255, 255, 255, 230))
        for t in TASKS:
            x, y = t[3]; d.rectangle([x-9, y-9, x+9, y+9], outline=(255, 210, 40), width=3)
        for (x, y) in HIDES: d.rectangle([x-13, y-13, x+13, y+13], outline=(60, 160, 255), width=2)
        for cells in (DOOR_A, DOOR_B):
            c, r = cells[0]; d.rectangle([c*T+2, r*T, c*T+30, r*T+63], fill=(200, 40, 40, 200))
        x, y = EXIT_POS; d.rectangle([x-22, y-11, x+22, y+11], fill=(40, 200, 90, 220))
        for k, (x, y) in SPAWNS.items():
            col = (60, 255, 120) if k.startswith('Player') else (255, 60, 60) if k.startswith('Enemy') else (255, 120, 120) if k.startswith('Patrol') else (200, 120, 255)
            d.ellipse([x-5, y-5, x+5, y+5], fill=col)
    if scale != 1: img = img.resize((int(img.width*scale), int(img.height*scale)), Image.LANCZOS)
    img.save(path)

def katalog(G, path):
    pat = G['pat']; s = 2
    big = pat.resize((pat.width*s, pat.height*s), Image.NEAREST)
    can = Image.new('RGBA', (big.width, big.height+20), (35, 35, 45, 255))
    d = ImageDraw.Draw(can)
    for x in range(0, big.width, T*s): d.line([(x, 0), (x, big.height)], fill=(70, 70, 90))
    for y in range(0, big.height, T*s): d.line([(0, y), (big.width, y)], fill=(70, 70, 90))
    can.alpha_composite(big)
    for n in G['used_names']:
        x, y = G['prop_pos'][n]; im = PROPS[n][0]
        d.rectangle([x*T*s, y*T*s, (x+im.width//T)*T*s-1, (y+im.height//T)*T*s-1], outline=(255, 200, 60))
        d.text((x*T*s+3, y*T*s+2), n, fill=(255, 255, 255))
    can.save(path)


if __name__ == '__main__':
    G = build()
    probs = check(G)
    print('wall tiles:', len(G['wall_imgs']), 'prop tiles:', len(G['prop_tiles']), 'props:', len(G['props']), 'kecil:', len(G['small']))
    print('\n'.join(probs) if probs else 'CEK OK')
    preview(G, '/home/claude/work/v2_full.png', markers=False)
    preview(G, '/home/claude/work/v2_small.png', scale=0.5)
