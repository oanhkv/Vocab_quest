# -*- coding: utf-8 -*-
"""Wireframe basic (black & white) cho VocabQuest — xuat file .drawio.

Moi man hinh = 1 page. Shape chi la box viem den + text, khong mau,
khong icon emoji — dung cho phac thao y tuong giao dien (low-fi).
"""

import os
from xml.sax.saxutils import escape

OUT_PATH = r"C:\Users\Kieu Anh\Desktop\CD2\VocabQuest_Wireframes.drawio"

# ============ Basic wireframe styles ============
S_PHONE = ('rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;'
           'strokeColor=#000000;strokeWidth=2;arcSize=6;verticalAlign=top;')
S_BOX = ('rounded=0;whiteSpace=wrap;html=1;fillColor=#FFFFFF;'
         'strokeColor=#000000;strokeWidth=1;fontSize=10;align=center;'
         'verticalAlign=middle;')
S_BOX_DASH = ('rounded=0;whiteSpace=wrap;html=1;fillColor=#FFFFFF;'
              'strokeColor=#000000;strokeWidth=1;dashed=1;fontSize=10;'
              'align=center;verticalAlign=middle;')
S_BOX_HDR = ('rounded=0;whiteSpace=wrap;html=1;fillColor=#EEEEEE;'
             'strokeColor=#000000;strokeWidth=1;fontSize=11;fontStyle=1;'
             'align=center;verticalAlign=middle;')
S_BOX_BTN = ('rounded=1;whiteSpace=wrap;html=1;fillColor=#F5F5F5;'
             'strokeColor=#000000;strokeWidth=2;fontSize=11;fontStyle=1;'
             'align=center;verticalAlign=middle;arcSize=25;')
S_BOX_LARGE = ('rounded=0;whiteSpace=wrap;html=1;fillColor=#FFFFFF;'
               'strokeColor=#000000;strokeWidth=1;fontSize=11;align=center;'
               'verticalAlign=top;spacingTop=10;')
S_CIRCLE = ('ellipse;whiteSpace=wrap;html=1;fillColor=#FFFFFF;'
            'strokeColor=#000000;strokeWidth=1;align=center;fontSize=10;'
            'verticalAlign=middle;')
S_TEXT = ('text;html=1;align=left;verticalAlign=middle;resizable=0;'
          'points=[];autosize=0;strokeColor=none;fillColor=none;'
          'fontSize=10;')
S_TEXT_BOLD = S_TEXT + 'fontStyle=1;fontSize=11;'
S_TEXT_SM = S_TEXT + 'fontSize=9;fontColor=#666666;'
S_TEXT_CENTER = S_TEXT + 'align=center;'
S_NOTE = ('shape=note;whiteSpace=wrap;html=1;backgroundOutline=1;'
          'fillColor=#FFF8DC;strokeColor=#B8860B;fontSize=10;'
          'align=left;spacingLeft=8;spacingRight=8;spacingTop=6;'
          'verticalAlign=top;')
S_ARROW = ('endArrow=classic;html=1;rounded=0;strokeColor=#666666;'
           'strokeWidth=1;startSize=6;endSize=6;dashed=1;')
S_OVERLAY = ('rounded=0;whiteSpace=wrap;html=1;fillColor=#000000;'
             'strokeColor=none;opacity=30;')
S_MODAL = ('rounded=1;whiteSpace=wrap;html=1;fillColor=#FFFFFF;'
           'strokeColor=#000000;strokeWidth=2;fontSize=11;align=center;'
           'verticalAlign=top;arcSize=10;')
S_DIVIDER = ('rounded=0;whiteSpace=wrap;html=1;fillColor=#000000;'
             'strokeColor=none;')

# ============ Constants ============
PHONE_X = 40
PHONE_Y = 40
PHONE_W = 360
PHONE_H = 720
STATUS_H = 20
APPBAR_H = 40
NOTE_X = 460
NOTE_COL_W = 420

# ============ ID counter ============
_counter = [2]


def nid():
    _counter[0] += 1
    return f'c{_counter[0]}'


# ============ Cell helpers ============

class Cell:
    def __init__(self, cid, value, style, x, y, w, h, edge=False,
                 source=None, target=None):
        self.cid = cid
        self.value = value
        self.style = style
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.edge = edge
        self.source = source
        self.target = target

    def to_xml(self):
        # Phai escape ca " vi gia tri nam trong "..." attribute
        val = escape(self.value or '', {'"': '&quot;'}) \
            .replace('\n', '&#10;')
        if self.edge:
            return (
                f'<mxCell id="{self.cid}" value="{val}" style="{self.style}" '
                f'edge="1" source="{self.source}" target="{self.target}" '
                f'parent="1"><mxGeometry relative="1" as="geometry" />'
                f'</mxCell>'
            )
        return (
            f'<mxCell id="{self.cid}" value="{val}" style="{self.style}" '
            f'vertex="1" parent="1">'
            f'<mxGeometry x="{self.x}" y="{self.y}" '
            f'width="{self.w}" height="{self.h}" as="geometry" />'
            f'</mxCell>'
        )


def box(cells, value, style, x, y, w, h):
    cid = nid()
    cells.append(Cell(cid, value, style, x, y, w, h))
    return cid


def arrow(cells, src, tgt):
    cid = nid()
    cells.append(Cell(cid, '', S_ARROW, 0, 0, 0, 0,
                      edge=True, source=src, target=tgt))
    return cid


def note(cells, text, x, y, w=420, h=60, target_cell=None):
    cid = box(cells, text, S_NOTE, x, y, w, h)
    if target_cell:
        arrow(cells, cid, target_cell)
    return cid


# ============ Phone frame ============

def phone_frame(cells, appbar_title='(App bar)'):
    box(cells, '', S_PHONE, PHONE_X, PHONE_Y, PHONE_W, PHONE_H)
    # Status bar
    box(cells, 'Status bar', S_BOX_DASH + 'fontColor=#999999;',
        PHONE_X, PHONE_Y, PHONE_W, STATUS_H)
    # App bar
    app_id = box(cells, appbar_title, S_BOX_HDR,
                 PHONE_X, PHONE_Y + STATUS_H, PHONE_W, APPBAR_H)
    return app_id


def content_y_start():
    return PHONE_Y + STATUS_H + APPBAR_H + 8


# ============ Screen registry ============

SCREENS = []


def screen(name):
    def deco(fn):
        SCREENS.append((name, fn))
        return fn
    return deco


# ---------- 01. Splash ----------
@screen('01. Splash')
def s_splash(cells):
    phone_frame(cells, '(không có app bar)')
    cy = content_y_start()
    logo = box(cells, 'LOGO', S_CIRCLE + 'fontSize=14;',
               PHONE_X + 130, cy + 180, 100, 100)
    title = box(cells, 'VOCABQUEST',
                S_TEXT_BOLD + 'align=center;fontSize=18;',
                PHONE_X + 40, cy + 300, 280, 30)
    box(cells, 'Tagline: Học từ vựng qua mini game',
        S_TEXT_SM + 'align=center;',
        PHONE_X + 40, cy + 330, 280, 20)
    box(cells, '(loader / progress)', S_TEXT_CENTER,
        PHONE_X + 40, cy + 420, 280, 20)

    note(cells,
         'SPLASH SCREEN\n\n'
         '- Hiển thị 1-2s khi mở app\n'
         '- Init Firebase + Audio + Notification service\n'
         '- Check auth state:\n'
         '  · Có user -> push /home\n'
         '  · Chưa    -> push /login',
         NOTE_X, PHONE_Y + 180, NOTE_COL_W, 160, logo)


# ---------- 02. Login ----------
@screen('02. Login')
def s_login(cells):
    phone_frame(cells, 'Đăng nhập')
    cy = content_y_start()

    box(cells, 'Chào mừng trở lại',
        S_TEXT_BOLD + 'align=center;fontSize=16;',
        PHONE_X + 20, cy + 20, 320, 30)

    box(cells, 'Email', S_TEXT_SM,
        PHONE_X + 20, cy + 70, 80, 16)
    email = box(cells, '[ Input: email ]', S_BOX,
                PHONE_X + 20, cy + 88, 320, 40)

    box(cells, 'Mật khẩu', S_TEXT_SM,
        PHONE_X + 20, cy + 140, 80, 16)
    pw = box(cells, '[ Input: password ]', S_BOX,
             PHONE_X + 20, cy + 158, 320, 40)

    box(cells, 'Quên mật khẩu?', S_TEXT + 'align=right;',
        PHONE_X + 20, cy + 205, 320, 20)

    btn = box(cells, 'ĐĂNG NHẬP', S_BOX_BTN,
              PHONE_X + 20, cy + 240, 320, 46)

    box(cells, '— hoặc —', S_TEXT_SM + 'align=center;',
        PHONE_X + 20, cy + 310, 320, 20)

    box(cells, 'Chưa có tài khoản? Đăng ký ngay',
        S_TEXT_CENTER, PHONE_X + 20, cy + 360, 320, 20)

    note(cells,
         'LOGIN SCREEN\n\n'
         '- Validate email format + password ≥ 6 ký tự\n'
         '- Loading spinner khi đang xác thực\n'
         '- Error: snackbar đỏ (sai pass/email)\n'
         '- "Quên mật khẩu" -> dialog gửi email reset\n'
         '- "Đăng ký ngay" -> push /register',
         NOTE_X, cy + 88, NOTE_COL_W, 160, btn)


# ---------- 03. Register ----------
@screen('03. Register')
def s_register(cells):
    phone_frame(cells, 'Đăng ký')
    cy = content_y_start()

    box(cells, 'Tạo tài khoản mới',
        S_TEXT_BOLD + 'align=center;fontSize=16;',
        PHONE_X + 20, cy + 20, 320, 30)

    fields = [
        ('Tên hiển thị', '[ Input: name ]'),
        ('Email', '[ Input: email ]'),
        ('Mật khẩu (≥ 6 ký tự)', '[ Input: password ]'),
        ('Xác nhận mật khẩu', '[ Input: confirm ]'),
    ]
    target = None
    for i, (lbl, inp) in enumerate(fields):
        y0 = cy + 70 + i * 65
        box(cells, lbl, S_TEXT_SM, PHONE_X + 20, y0, 180, 16)
        bid = box(cells, inp, S_BOX,
                  PHONE_X + 20, y0 + 18, 320, 40)
        if i == 2:
            target = bid

    btn = box(cells, 'ĐĂNG KÝ', S_BOX_BTN,
              PHONE_X + 20, cy + 340, 320, 46)

    note(cells,
         'REGISTER SCREEN\n\n'
         '- Tạo user Firebase Auth + tạo doc Firestore\n'
         '- User mặc định được tặng:\n'
         '  · 100 coin welcome\n'
         '  · Free pack beginner/intermediate/advanced\n'
         '- streak=0, level=1, XP=0\n'
         '- Tự push /home sau khi thành công',
         NOTE_X, cy + 180, NOTE_COL_W, 180, target)


# ---------- 04. Home ----------
@screen('04. Home')
def s_home(cells):
    phone_frame(cells, 'Home')
    cy = content_y_start()

    # Hero
    avatar = box(cells, 'Avatar', S_CIRCLE,
                 PHONE_X + 16, cy + 10, 48, 48)
    box(cells, 'Xin chào\nTên User',
        S_TEXT + 'spacingLeft=8;', PHONE_X + 72, cy + 14, 150, 40)
    streak = box(cells, 'Chip:\nStreak N', S_BOX,
                 PHONE_X + 230, cy + 16, 60, 40)
    box(cells, 'Nút\nSetting', S_CIRCLE,
        PHONE_X + 300, cy + 14, 40, 40)

    # Stats strip
    stats = box(cells,
                '[ Stats strip ]\n\n'
                'Điểm   |   Coin   |   XP\n'
                '(3 ô chia đều)',
                S_BOX + 'verticalAlign=top;spacingTop=8;',
                PHONE_X + 16, cy + 80, 328, 70)

    # Daily challenge
    ch = box(cells,
             '[ Thử thách hôm nay ]\n\n'
             'Tiêu đề + mô tả\n\n'
             'Progress bar ______\n'
             'X / 50 XP',
             S_BOX_LARGE,
             PHONE_X + 16, cy + 165, 328, 120)

    box(cells, 'Section: Chơi ngay', S_TEXT_BOLD,
        PHONE_X + 16, cy + 295, 200, 20)

    # 4 tiles 2x2
    box(cells, 'Mini Game\n\n(mô tả)', S_BOX,
        PHONE_X + 16, cy + 320, 158, 80)
    box(cells, 'Xếp hạng\n\n(mô tả)', S_BOX,
        PHONE_X + 186, cy + 320, 158, 80)
    box(cells, 'Lịch sử\n\n(mô tả)', S_BOX,
        PHONE_X + 16, cy + 410, 158, 80)
    box(cells, 'Cửa hàng\n\n(mô tả)', S_BOX,
        PHONE_X + 186, cy + 410, 158, 80)

    box(cells, 'Section: Khám phá', S_TEXT_BOLD,
        PHONE_X + 16, cy + 500, 200, 20)

    # Shortcuts row
    for i, lbl in enumerate(['Hồ sơ', 'Cài đặt', 'Huy hiệu', 'Đã lưu']):
        box(cells, lbl, S_BOX,
            PHONE_X + 16 + i * 84, cy + 525, 75, 60)

    note(cells,
         'HOME SCREEN\n\n'
         '- Hero: avatar + tên + streak chip + icon setting\n'
         '- Stats strip: điểm/coin/XP (realtime từ provider)\n'
         '- Daily challenge: banner có progress XP hôm nay\n'
         '- 4 action tiles grid 2x2 dẫn tới phân hệ chính\n'
         '- 4 shortcuts tròn: Profile, Settings, Badges, Favorites\n'
         '- Pull-to-refresh để sync user từ Firestore',
         NOTE_X, cy + 80, NOTE_COL_W, 220, stats)


# ---------- 05. Settings ----------
@screen('05. Settings')
def s_settings(cells):
    phone_frame(cells, 'Cài đặt')
    cy = content_y_start()

    # Profile card
    pc = box(cells,
             '[ Profile card ]\n\n'
             'Avatar | Tên | email | mini stats',
             S_BOX_LARGE,
             PHONE_X + 16, cy + 10, 328, 80)

    # Appearance
    box(cells, 'Giao diện', S_TEXT_BOLD,
        PHONE_X + 16, cy + 105, 200, 20)
    box(cells, 'Chế độ tối                                  [ switch ]',
        S_BOX + 'align=left;spacingLeft=12;',
        PHONE_X + 16, cy + 128, 328, 40)

    # Sound
    box(cells, 'Âm thanh', S_TEXT_BOLD,
        PHONE_X + 16, cy + 180, 200, 20)
    sd = box(cells,
             'Hiệu ứng âm thanh                       [ switch ]\n'
             '— — — — — — — — — — — —\n'
             'Nhạc nền                                           [ switch ]',
             S_BOX + 'align=left;spacingLeft=12;verticalAlign=top;'
             'spacingTop=8;',
             PHONE_X + 16, cy + 203, 328, 80)

    # Notification
    box(cells, 'Thông báo', S_TEXT_BOLD,
        PHONE_X + 16, cy + 295, 200, 20)
    nt = box(cells,
             'Nhắc nhở học tập                              [ switch ]\n'
             '— — — — — — — — — — — —\n'
             'Giờ nhắc hàng ngày                     HH:MM  >',
             S_BOX + 'align=left;spacingLeft=12;verticalAlign=top;'
             'spacingTop=8;',
             PHONE_X + 16, cy + 318, 328, 80)

    # Language
    box(cells, 'Ngôn ngữ', S_TEXT_BOLD,
        PHONE_X + 16, cy + 410, 200, 20)
    box(cells, 'Ngôn ngữ giao diện                  Tiếng Việt  >',
        S_BOX + 'align=left;spacingLeft=12;',
        PHONE_X + 16, cy + 433, 328, 40)

    # Logout
    btn = box(cells, 'ĐĂNG XUẤT', S_BOX_BTN,
              PHONE_X + 16, cy + 490, 328, 46)

    note(cells,
         'SETTINGS SCREEN\n\n'
         '- Mỗi section là 1 card\n'
         '- Switch: toggle đồng bộ SettingsProvider\n'
         '- Giờ nhắc: tap mở time picker 24h\n'
         '- Đổi ngôn ngữ: bottom sheet VI/EN -> tất cả màn\n'
         '  tự đổi ngôn ngữ nhờ context.t(key)\n'
         '- Logout: show confirm dialog -> clear session',
         NOTE_X, cy + 295, NOTE_COL_W, 180, nt)


# ---------- 06. Edit Profile ----------
@screen('06. Edit Profile')
def s_edit_profile(cells):
    phone_frame(cells, 'Chỉnh sửa hồ sơ')
    cy = content_y_start()

    # Avatar + camera badge
    av = box(cells, 'Avatar\nlớn', S_CIRCLE + 'fontSize=12;',
             PHONE_X + 130, cy + 30, 100, 100)
    cam = box(cells, 'Nút\ncamera', S_CIRCLE,
              PHONE_X + 210, cy + 100, 40, 40)

    box(cells, 'Tên hiển thị', S_TEXT_SM,
        PHONE_X + 20, cy + 170, 100, 16)
    name = box(cells, '[ Input: tên user ]', S_BOX,
               PHONE_X + 20, cy + 190, 320, 44)

    box(cells, 'Email (readonly)', S_TEXT_SM,
        PHONE_X + 20, cy + 250, 200, 16)
    box(cells, '[ Input disabled: email ]', S_BOX_DASH,
        PHONE_X + 20, cy + 270, 320, 44)

    btn = box(cells, 'LƯU THAY ĐỔI', S_BOX_BTN,
              PHONE_X + 20, cy + 450, 320, 50)

    note(cells,
         'EDIT PROFILE SCREEN\n\n'
         '- Tap avatar / nút camera -> bottom sheet 2 option:\n'
         '  · Chụp ảnh (camera)\n'
         '  · Chọn từ thư viện\n'
         '- image_picker resize 400x400 quality 75\n'
         '- Lưu: base64 encode -> Firestore avatarUrl\n'
         '- Giới hạn 500KB (doc Firestore ≤ 1MB)\n'
         '- Email readonly — không đổi được qua UI',
         NOTE_X, cy + 30, NOTE_COL_W, 200, cam)


# ---------- 07. Profile ----------
@screen('07. Profile')
def s_profile(cells):
    phone_frame(cells, 'Hồ sơ')
    cy = content_y_start()

    # Header big
    header = box(cells,
                 '[ Header gradient ]\n\n'
                 'Avatar lớn (có badge Level)\n\n'
                 'Tên User\n'
                 'email@domain\n\n'
                 '[ Progress bar: Cấp N / XP / next ]',
                 S_BOX_LARGE,
                 PHONE_X + 16, cy + 10, 328, 220)

    # Stats grid 3
    s1 = box(cells, 'Điểm\n\nN', S_BOX,
             PHONE_X + 16, cy + 245, 100, 70)
    box(cells, 'Coin\n\nN', S_BOX,
        PHONE_X + 130, cy + 245, 100, 70)
    box(cells, 'Streak\n(kỷ lục M)\n\nN', S_BOX,
        PHONE_X + 244, cy + 245, 100, 70)

    # Game stats
    gs = box(cells,
             '[ Thống kê game ]\n\n'
             'Tổng | Nối từ | Quiz | Xếp chữ | Lật thẻ',
             S_BOX_LARGE,
             PHONE_X + 16, cy + 330, 328, 90)

    # Menu
    box(cells, 'Lịch sử chơi                                       >',
        S_BOX + 'align=left;spacingLeft=14;',
        PHONE_X + 16, cy + 440, 328, 42)
    box(cells, 'Bảng xếp hạng                                >',
        S_BOX + 'align=left;spacingLeft=14;',
        PHONE_X + 16, cy + 486, 328, 42)
    box(cells, 'Cài đặt                                                   >',
        S_BOX + 'align=left;spacingLeft=14;',
        PHONE_X + 16, cy + 532, 328, 42)

    note(cells,
         'PROFILE SCREEN\n\n'
         '- Header: back + "Hồ sơ" + setting icon\n'
         '- Avatar lớn + badge Level bên dưới\n'
         '- XP progress bar reactive\n'
         '- Stats: Điểm / Coin / Streak (kỷ lục)\n'
         '- Thống kê game: count từ getGameStats() Firestore\n'
         '- Icon bút cạnh tên -> push EditProfileScreen\n'
         '- Streak label đổi "Streak (kỷ lục X)" nếu longest>hiện tại',
         NOTE_X, cy + 10, NOTE_COL_W, 240, header)


# ---------- 08. Game Menu ----------
@screen('08. Game Menu')
def s_game_menu(cells):
    phone_frame(cells, 'Mini Game')
    cy = content_y_start()

    # Hero
    hero = box(cells,
               '[ Hero banner ]\n\n'
               'Tiêu đề + mô tả\n\n'
               'Streak | XP | Điểm (3 mini-stats)',
               S_BOX_LARGE,
               PHONE_X + 16, cy + 10, 328, 130)

    box(cells, 'Gợi ý hôm nay', S_TEXT_BOLD,
        PHONE_X + 16, cy + 155, 200, 20)

    feat = box(cells,
               '[ Featured card (lớn) ]\n\n'
               'Icon | Tên game | Badge HOT\n'
               'Mô tả ngắn\n'
               '[ Nút: Chơi ngay ]\n\n'
               '(Icon tim yêu thích góc phải)',
               S_BOX_LARGE,
               PHONE_X + 16, cy + 180, 328, 150)

    box(cells, 'Tất cả mini game', S_TEXT_BOLD,
        PHONE_X + 16, cy + 345, 200, 20)

    # 3 cards grid 2 cột
    box(cells, 'Game B\n\n(icon)\n(mô tả)\n\n<tim>',
        S_BOX, PHONE_X + 16, cy + 375, 158, 140)
    box(cells, 'Game C\n\n(icon)\n(mô tả)\nbadge MỚI\n\n<tim>',
        S_BOX, PHONE_X + 186, cy + 375, 158, 140)
    box(cells, 'Game D\n\n(icon)\n(mô tả)\n\n<tim>',
        S_BOX, PHONE_X + 16, cy + 525, 158, 140)

    note(cells,
         'GAME MENU SCREEN\n\n'
         '- Hero banner + 3 mini-stats (streak/XP/score)\n'
         '- Featured card (1 game HOT): lớn, có pulse/shimmer\n'
         '- Grid 2 cột cho các game còn lại\n'
         '- Mỗi card có icon tim góc phải-trên để toggle favorite\n'
         '- Badge "MỚI" / "HOT" cho game có highlight\n'
         '- Tap card -> haptic feedback -> PackSelection',
         NOTE_X, cy + 180, NOTE_COL_W, 220, feat)


# ---------- 09. Pack Selection ----------
@screen('09. Pack Selection')
def s_pack(cells):
    phone_frame(cells, 'Chọn gói từ vựng')
    cy = content_y_start()

    # Grid 2 cột
    positions = [
        ('Pack 1 (sơ cấp)\n\n- 100 từ\n- Đã sở hữu\n- Tiến độ: 5/9',
         PHONE_X + 16, cy + 10),
        ('Pack 2 (trung cấp)\n\n- 150 từ\n- Đã sở hữu\n- Tiến độ: 2/9',
         PHONE_X + 186, cy + 10),
        ('Pack 3 (nâng cao)\n\n- 200 từ\n- Đã sở hữu\n- Tiến độ: 0/9',
         PHONE_X + 16, cy + 180),
        ('Pack 4 (trả phí)\n\n- N từ\n- Khóa\n- Giá: X coin\n'
         '[ Mua ngay ]',
         PHONE_X + 186, cy + 180),
    ]
    target = None
    for i, (t, x, y) in enumerate(positions):
        cid = box(cells, t, S_BOX_LARGE, x, y, 158, 160)
        if i == 1:
            target = cid

    note(cells,
         'PACK SELECTION SCREEN\n\n'
         '- Grid 2 cột các pack user có thể truy cập\n'
         '- Pack đã sở hữu: hiển thị tiến độ level đã pass\n'
         '- Pack chưa mua: có icon khóa + giá + nút "Mua"\n'
         '- Tap pack đã sở hữu -> push LevelMapScreen\n'
         '- Tap pack chưa mua -> push ShopScreen purchase\n'
         '- Data: PackService.loadOwnedPacks()',
         NOTE_X, cy + 30, NOTE_COL_W, 200, target)


# ---------- 10. Level Map ----------
@screen('10. Level Map')
def s_levelmap(cells):
    phone_frame(cells, 'Tên pack — Tên game')
    cy = content_y_start()

    # Zigzag 4 level circles
    lv1 = box(cells, 'Level 1\n(pass)\n3 sao', S_CIRCLE + 'fontSize=10;',
              PHONE_X + 70, cy + 30, 80, 80)
    lv2 = box(cells, 'Level 2\n(current)\n2 sao', S_CIRCLE + 'fontSize=10;',
              PHONE_X + 210, cy + 130, 80, 80)
    lv3 = box(cells, 'Level 3\n(locked)', S_CIRCLE + 'fontSize=10;',
              PHONE_X + 70, cy + 230, 80, 80)

    arrow(cells, lv1, lv2)
    arrow(cells, lv2, lv3)

    # Reward hint
    box(cells,
        '[ Reward hint ]\n\n'
        'Pass level mới nhận +Coin +XP\n'
        '- Lv1: 30c/20xp\n'
        '- Lv2: 60c/40xp\n'
        '- Lv3: 150c/100xp',
        S_BOX_LARGE, PHONE_X + 30, cy + 380, 300, 120)

    note(cells,
         'LEVEL MAP SCREEN\n\n'
         '- Zigzag path 3 level (Duolingo-style)\n'
         '- Level đã pass: có số sao đã đạt\n'
         '- Level current unlock: nổi bật\n'
         '- Level locked: disabled (cần pass level trước)\n'
         '- Tap level -> launch game tương ứng\n'
         '- Reward chỉ nhận 1 lần cho lần đầu pass ≥2 sao',
         NOTE_X, cy + 30, NOTE_COL_W, 220, lv2)


# ---------- 11. Matching Game ----------
@screen('11. Matching Game')
def s_matching(cells):
    phone_frame(cells, '(không app bar)')
    cy = content_y_start()

    # Top bar in-game
    box(cells, 'X   |   Score: N   |   Timer: Ns   |   Round: x/y',
        S_BOX_HDR + 'align=left;spacingLeft=10;',
        PHONE_X, cy, PHONE_W, 36)

    # Labels
    box(cells, 'Cột từ (EN)', S_TEXT_SM + 'align=center;',
        PHONE_X + 16, cy + 46, 150, 16)
    box(cells, 'Cột nghĩa (VI)', S_TEXT_SM + 'align=center;',
        PHONE_X + 194, cy + 46, 150, 16)

    # 4 word + 4 meaning
    states = [
        ('Word 1', 'normal'),
        ('Word 2\n(matched)', 'matched'),
        ('Word 3', 'normal'),
        ('Word 4', 'normal'),
    ]
    mstates = [
        ('Meaning A', 'normal'),
        ('Meaning B\n(matched)', 'matched'),
        ('Meaning C\n(WRONG)', 'wrong'),
        ('Meaning D', 'normal'),
    ]
    wrong_id = None
    for i, (t, st) in enumerate(states):
        style = S_BOX
        if st == 'matched':
            style = S_BOX + 'strokeWidth=3;'
        box(cells, t, style,
            PHONE_X + 16, cy + 72 + i * 105, 150, 95)
    for i, (t, st) in enumerate(mstates):
        style = S_BOX
        if st == 'matched':
            style = S_BOX + 'strokeWidth=3;'
        elif st == 'wrong':
            style = S_BOX + 'strokeWidth=3;dashed=1;'
        cid = box(cells, t, style,
                  PHONE_X + 194, cy + 72 + i * 105, 150, 95)
        if st == 'wrong':
            wrong_id = cid

    note(cells,
         'MATCHING GAME (Nối từ)\n\n'
         '- Top bar: X (thoát) | Score | Timer 60s | Round\n'
         '- 2 cột 4 cặp/round, 3 rounds -> max 120đ\n'
         '- Tap word -> tap meaning -> check match\n'
         '- Đúng: viền dày (xanh), persistent\n'
         '- Sai: viền dashed (đỏ) 600ms rồi reset\n'
         '- +10đ chỉ cho lần đầu đúng mỗi cặp\n'
         '- Back gesture hoặc X -> confirm dialog',
         NOTE_X, cy + 72, NOTE_COL_W, 220, wrong_id)


# ---------- 12. Quiz ----------
@screen('12. Quiz Game')
def s_quiz(cells):
    phone_frame(cells, '(không app bar)')
    cy = content_y_start()

    box(cells, 'X | Score: N | Timer câu: Ns | Câu: i/10',
        S_BOX_HDR + 'align=left;spacingLeft=10;',
        PHONE_X, cy, PHONE_W, 36)

    q = box(cells,
            '[ Card câu hỏi ]\n\n'
            'Câu i/10\n\n'
            'TỪ TIẾNG ANH (lớn)\n\n'
            '[nút phát âm loa]',
            S_BOX_LARGE,
            PHONE_X + 16, cy + 50, 328, 160)

    # 4 options
    box(cells, 'A. Đáp án 1 (đúng — xanh)', S_BOX + 'align=left;spacingLeft=20;',
        PHONE_X + 16, cy + 220, 328, 50)
    box(cells, 'B. Đáp án 2', S_BOX + 'align=left;spacingLeft=20;',
        PHONE_X + 16, cy + 280, 328, 50)
    box(cells, 'C. Đáp án 3', S_BOX + 'align=left;spacingLeft=20;',
        PHONE_X + 16, cy + 340, 328, 50)
    box(cells, 'D. Đáp án 4', S_BOX + 'align=left;spacingLeft=20;',
        PHONE_X + 16, cy + 400, 328, 50)

    # Progress bar
    box(cells, '[ Progress bar câu hỏi ]',
        S_BOX_DASH, PHONE_X + 16, cy + 470, 328, 24)

    note(cells,
         'QUIZ GAME\n\n'
         '- 10 câu, mỗi câu timer 15s\n'
         '- Từ tiếng Anh hiển thị + nút TTS phát âm\n'
         '- 4 đáp án shuffled\n'
         '- Tap:\n'
         '  · Đúng: viền xanh + +(10+timeLeft) điểm\n'
         '  · Sai: viền đỏ + highlight đáp án đúng\n'
         '- Timeout = sai, auto chuyển câu sau 2s\n'
         '- Progress bar cập nhật theo câu hiện tại',
         NOTE_X, cy + 50, NOTE_COL_W, 230, q)


# ---------- 13. Word Puzzle ----------
@screen('13. Word Puzzle')
def s_puzzle(cells):
    phone_frame(cells, '(không app bar)')
    cy = content_y_start()

    box(cells, 'X | Score: N | Hint (-10 coin) | Từ: i/5',
        S_BOX_HDR + 'align=left;spacingLeft=10;',
        PHONE_X, cy, PHONE_W, 36)

    # Meaning + TTS
    mn = box(cells,
             '[ Nghĩa của từ ]\n\n'
             'Tiếng Việt\n\n'
             '[nút phát âm loa]',
             S_BOX_LARGE,
             PHONE_X + 16, cy + 50, 328, 100)

    # Answer slots (filled + empty)
    box(cells, 'Answer slots', S_TEXT_SM,
        PHONE_X + 16, cy + 160, 200, 16)
    box(cells, 'C', S_BOX + 'fontStyle=1;fontSize=16;',
        PHONE_X + 60, cy + 180, 40, 40)
    box(cells, 'A', S_BOX + 'fontStyle=1;fontSize=16;',
        PHONE_X + 110, cy + 180, 40, 40)
    box(cells, '_', S_BOX_DASH + 'fontStyle=1;fontSize=16;',
        PHONE_X + 160, cy + 180, 40, 40)
    box(cells, '_', S_BOX_DASH + 'fontStyle=1;fontSize=16;',
        PHONE_X + 210, cy + 180, 40, 40)

    # Shuffled letters
    box(cells, 'Shuffled letters', S_TEXT_SM,
        PHONE_X + 16, cy + 240, 200, 16)
    for i, L in enumerate(['T', 'A', 'C', 'P']):
        used = i in (1, 2)
        st = S_BOX_DASH if used else S_BOX
        box(cells, f"{L}{' (used)' if used else ''}",
            st + 'fontStyle=1;fontSize=14;',
            PHONE_X + 30 + i * 80, cy + 260, 60, 40)

    # Buttons
    btn_clr = box(cells, 'XÓA', S_BOX_BTN,
                  PHONE_X + 60, cy + 340, 120, 40)
    btn_hnt = box(cells, 'HINT (-10 coin)', S_BOX_BTN,
                  PHONE_X + 200, cy + 340, 140, 40)

    note(cells,
         'WORD PUZZLE GAME\n\n'
         '- 5 từ/game, không có timer tổng\n'
         '- Nghĩa hiển thị trên, chữ cái shuffled dưới\n'
         '- Tap chữ -> điền vào ô trống gần nhất\n'
         '- Tap ô đã điền -> trả chữ về\n'
         '- Đủ chữ -> tự check đáp án\n'
         '- Đúng: +20đ. Sai: chuyển từ sau 1.8s\n'
         '- Hint: tiết lộ 1 chữ đúng, -10 coin',
         NOTE_X, cy + 50, NOTE_COL_W, 220, mn)


# ---------- 14. Memory ----------
@screen('14. Memory Game')
def s_memory(cells):
    phone_frame(cells, '(không app bar)')
    cy = content_y_start()

    box(cells, 'X | Score: N | Timer: Ns | Round: x/3',
        S_BOX_HDR + 'align=left;spacingLeft=10;',
        PHONE_X, cy, PHONE_W, 36)

    # 3x4 grid
    card_w = 100
    card_h = 80
    my = cy + 60
    labels = [
        ('(úp) EN hint', S_BOX),
        ('(ngửa)\nQuả táo\n[matched]', S_BOX + 'strokeWidth=3;'),
        ('(úp) VI hint', S_BOX),
        ('(úp) VI hint', S_BOX),
        ('(ngửa)\nApple\n[matched]', S_BOX + 'strokeWidth=3;'),
        ('(úp) EN hint', S_BOX),
        ('(ngửa)\nCat\n[đang lật]', S_BOX_DASH),
        ('(úp) EN hint', S_BOX),
        ('(ngửa)\nCon chó\n[đang lật]', S_BOX_DASH),
        ('(úp) VI hint', S_BOX),
        ('(úp) EN hint', S_BOX),
        ('(úp) VI hint', S_BOX),
    ]
    flipped_id = None
    for idx, (txt, st) in enumerate(labels):
        r = idx // 3
        c = idx % 3
        x = PHONE_X + 16 + c * (card_w + 10)
        y = my + r * (card_h + 10)
        cid = box(cells, txt, st + 'fontSize=9;', x, y, card_w, card_h)
        if idx == 6:
            flipped_id = cid

    note(cells,
         'MEMORY GAME (Lật thẻ)\n\n'
         '- Grid 3 × 4 = 12 thẻ (6 cặp word ↔ meaning)\n'
         '- Timer 90s, tối đa 3 rounds\n'
         '- Mặt úp: hiện "EN"/"VI" hint để user biết loại\n'
         '- Mặt ngửa: hiển thị nội dung text\n'
         '- Lật 2 thẻ:\n'
         '  · Match (cùng vocabId, khác loại): viền dày (matched)\n'
         '  · Không match: úp lại sau 800ms\n'
         '- +20đ chỉ cho lần đầu match mỗi cặp',
         NOTE_X, cy + 60, NOTE_COL_W, 240, flipped_id)


# ---------- 15. Game Result ----------
@screen('15. Game Result')
def s_result(cells):
    phone_frame(cells, '(không app bar)')
    cy = content_y_start()

    # Title
    box(cells, 'TUYỆT VỜI! / LÀM TỐT LẮM! / CỐ LÊN...',
        S_TEXT_BOLD + 'align=center;fontSize=16;',
        PHONE_X + 20, cy + 10, 320, 40)

    # Stars
    box(cells, '[ 1-3 sao ]',
        S_TEXT_CENTER + 'fontSize=18;',
        PHONE_X + 20, cy + 60, 320, 40)

    # Stats
    stats = box(cells,
                '[ Stats card ]\n\n'
                'Đúng: X/Y\n'
                'Thời gian: N giây\n'
                'Điểm: N',
                S_BOX_LARGE,
                PHONE_X + 20, cy + 115, 320, 130)

    # Rewards
    rwd = box(cells,
              '[ Reward card ]\n\n'
              '+X coin       +Y XP',
              S_BOX_LARGE,
              PHONE_X + 20, cy + 260, 320, 90)

    # Streak (optional)
    streak = box(cells,
                 '[ Streak celebration ]\n'
                 '(chỉ hiện khi đạt milestone 3/7/14/30/60/100)\n\n'
                 'Streak N ngày!\n+X coin bonus +Y XP bonus',
                 S_BOX_LARGE,
                 PHONE_X + 20, cy + 365, 320, 110)

    # Buttons
    btn_again = box(cells, 'CHƠI LẠI', S_BOX_BTN,
                    PHONE_X + 20, cy + 490, 150, 46)
    btn_next = box(cells, 'TIẾP THEO', S_BOX_BTN,
                   PHONE_X + 180, cy + 490, 160, 46)

    note(cells,
         'GAME RESULT SCREEN\n\n'
         '- Confetti nếu ≥2 sao HOẶC đạt milestone streak\n'
         '- Tiêu đề theo số sao:\n'
         '  · 3 sao: "Tuyệt vời!"\n'
         '  · 2 sao: "Làm tốt lắm!"\n'
         '  · 1 sao: "Cố lên nhé!"\n'
         '  · 0 sao: "Hãy thử lại!"\n'
         '- Streak banner hiển thị nếu milestoneHit != null\n'
         '- Nút "Tiếp theo" chỉ hiện khi ≥2 sao + còn level',
         NOTE_X, cy + 260, NOTE_COL_W, 220, streak)


# ---------- 16. Shop ----------
@screen('16. Shop')
def s_shop(cells):
    phone_frame(cells, 'Cửa hàng')
    cy = content_y_start()

    # Balance
    bal = box(cells, '[ Coin balance: X coin ]',
              S_BOX, PHONE_X + 16, cy + 10, 328, 50)

    # 3 pack list
    for i in range(3):
        box(cells,
            f'Pack {i+1}\n\nTên pack\nMô tả ngắn\nGiá: X coin\n\n[ Mua ]',
            S_BOX_LARGE,
            PHONE_X + 16, cy + 80 + i * 115, 328, 100)

    note(cells,
         'SHOP SCREEN\n\n'
         '- Coin balance ở đầu trang\n'
         '- List pack có thể mua (chưa sở hữu)\n'
         '- Tap "Mua" -> dialog confirm\n'
         '- Xác nhận -> Firestore transaction atomic:\n'
         '  · Check đủ coin + chưa sở hữu\n'
         '  · Trừ coin + append ownedPacks\n'
         '- Snackbar xanh success / đỏ error',
         NOTE_X, cy + 80, NOTE_COL_W, 220, bal)


# ---------- 17. Leaderboard ----------
@screen('17. Leaderboard')
def s_leaderboard(cells):
    phone_frame(cells, 'Bảng xếp hạng')
    cy = content_y_start()

    # Tab
    box(cells, '[ Điểm  |  XP ]  tab switch',
        S_BOX_HDR, PHONE_X + 16, cy + 10, 328, 36)

    # Podium 3 user
    box(cells, 'Rank 2\nTên\nAvatar\nScore',
        S_BOX_LARGE, PHONE_X + 16, cy + 60, 100, 130)
    box(cells, 'Rank 1\nTên\nAvatar\nScore\n(nổi bật)',
        S_BOX_LARGE + 'strokeWidth=3;',
        PHONE_X + 130, cy + 40, 100, 150)
    box(cells, 'Rank 3\nTên\nAvatar\nScore',
        S_BOX_LARGE, PHONE_X + 244, cy + 80, 100, 110)

    # Rank list 4-N
    for i, rank in enumerate([4, 5, 6]):
        box(cells,
            f'{rank}   Avatar   Tên user                      Score',
            S_BOX + 'align=left;spacingLeft=12;',
            PHONE_X + 16, cy + 210 + i * 45, 328, 40)

    # Me highlight
    me = box(cells,
             'N    Avatar   BẠN (highlight)                Score',
             S_BOX + 'align=left;spacingLeft=12;strokeWidth=3;',
             PHONE_X + 16, cy + 345, 328, 40)

    note(cells,
         'LEADERBOARD SCREEN\n\n'
         '- Tab chuyển Điểm / XP\n'
         '- Top 3 hiển thị podium (box to hơn cho rank 1)\n'
         '- List rank 4-100 bên dưới\n'
         '- Row "Bạn" luôn highlight viền dày\n'
         '- Data: streamLeaderboard() realtime\n'
         '- getUserRankByScore() lấy rank user hiện tại',
         NOTE_X, cy + 210, NOTE_COL_W, 200, me)


# ---------- 18. Favorites ----------
@screen('18. Favorites')
def s_fav(cells):
    phone_frame(cells, 'Game đã lưu')
    cy = content_y_start()

    for i in range(2):
        box(cells,
            f'Game yêu thích {i+1}\n\nIcon | Tên game | Mô tả\n\n(nút ❤ remove)',
            S_BOX_LARGE,
            PHONE_X + 16, cy + 10 + i * 110, 328, 100)

    empty = box(cells,
                '--- EMPTY STATE ---\n\n'
                '(icon trái tim lớn)\n\n'
                'Chưa có game yêu thích\n\n'
                'Gợi ý: vào Mini Game tap\n'
                'biểu tượng tim để lưu\n\n'
                '[ Xem tất cả mini game ]',
                S_BOX_LARGE,
                PHONE_X + 16, cy + 250, 328, 230)

    note(cells,
         'FAVORITES SCREEN\n\n'
         '- List game user đã tap tim (SharedPrefs local)\n'
         '- Tap game -> push PackSelectionScreen\n'
         '- Nút ❤ trong card -> bỏ yêu thích\n'
         '- Empty state:\n'
         '  · Icon tim pulse animation\n'
         '  · Nút "Xem tất cả mini game" -> /games',
         NOTE_X, cy + 250, NOTE_COL_W, 180, empty)


# ---------- 19. Popup Exit Game ----------
@screen('19. Popup — Thoát game')
def p_exit(cells):
    phone_frame(cells, '(game đang chơi)')
    cy = content_y_start()

    box(cells, '', S_OVERLAY,
        PHONE_X, PHONE_Y, PHONE_W, PHONE_H)

    box(cells, '(Game đang chơi mờ đi...)',
        S_TEXT_CENTER + 'fontColor=#999999;',
        PHONE_X + 16, cy + 100, 328, 40)

    modal = box(cells,
                'THOÁT GAME?\n\n'
                'Bạn sẽ mất tiến trình hiện tại.',
                S_MODAL + 'spacingTop=18;fontSize=12;',
                PHONE_X + 40, cy + 250, 280, 120)

    box(cells, 'CHƠI TIẾP', S_BOX_BTN,
        PHONE_X + 55, cy + 390, 120, 40)
    box(cells, 'THOÁT', S_BOX_BTN + 'strokeWidth=2;',
        PHONE_X + 185, cy + 390, 120, 40)

    note(cells,
         'POPUP — Thoát game\n\n'
         '- Trigger: tap X top bar hoặc back gesture\n'
         '- PopScope(canPop: false) chặn back, bật dialog\n'
         '- Chơi tiếp: dismiss dialog\n'
         '- Thoát: pop 2 lần (đóng dialog + pop game)\n'
         '- Tap outside dialog = dismiss',
         NOTE_X, cy + 250, NOTE_COL_W, 180, modal)


# ---------- 20. Popup Logout ----------
@screen('20. Popup — Đăng xuất')
def p_logout(cells):
    phone_frame(cells, 'Cài đặt')
    cy = content_y_start()

    box(cells, '', S_OVERLAY,
        PHONE_X, PHONE_Y, PHONE_W, PHONE_H)

    modal = box(cells,
                'ĐĂNG XUẤT?\n\n'
                'Bạn có chắc muốn đăng xuất không?',
                S_MODAL + 'spacingTop=18;fontSize=12;',
                PHONE_X + 40, cy + 250, 280, 120)

    box(cells, 'HỦY', S_BOX_BTN,
        PHONE_X + 55, cy + 390, 120, 40)
    box(cells, 'ĐĂNG XUẤT', S_BOX_BTN + 'strokeWidth=2;',
        PHONE_X + 185, cy + 390, 120, 40)

    note(cells,
         'POPUP — Đăng xuất\n\n'
         '- Trigger: tap nút Đăng xuất (Settings/Profile)\n'
         '- Xác nhận -> FirebaseAuth.signOut()\n'
         '- Clear UserProvider._user = null\n'
         '- Navigator.pushNamedAndRemoveUntil /login\n'
         '  (xóa toàn bộ stack)',
         NOTE_X, cy + 250, NOTE_COL_W, 160, modal)


# ---------- 21. Popup Time Picker ----------
@screen('21. Popup — Chọn giờ nhắc')
def p_time(cells):
    phone_frame(cells, 'Cài đặt')
    cy = content_y_start()

    box(cells, '', S_OVERLAY,
        PHONE_X, PHONE_Y, PHONE_W, PHONE_H)

    modal = box(cells,
                'CHỌN GIỜ\n\n\n'
                '[ Hour wheel ]  :  [ Minute wheel ]\n\n\n'
                '      HH             MM\n'
                '      (wheel)      (wheel)\n\n\n\n'
                '[ HỦY ]              [ OK ]',
                S_MODAL + 'spacingTop=15;fontSize=12;',
                PHONE_X + 30, cy + 150, 300, 340)

    note(cells,
         'POPUP — Time Picker\n\n'
         '- Trigger: tap row "Giờ nhắc hàng ngày"\n'
         '- showTimePicker() flutter built-in\n'
         '- 24h format (alwaysUse24HourFormat: true)\n'
         '- OK -> setReminderTime() + reschedule notif\n'
         '- Snackbar: "Đã đặt nhắc HH:MM"',
         NOTE_X, cy + 150, NOTE_COL_W, 180, modal)


# ---------- 22. Popup Image Source ----------
@screen('22. Popup — Chọn nguồn ảnh')
def p_image(cells):
    phone_frame(cells, 'Chỉnh sửa hồ sơ')
    cy = content_y_start()

    box(cells, '', S_OVERLAY,
        PHONE_X, PHONE_Y, PHONE_W, PHONE_H)

    sheet = box(cells,
                '──── (drag handle) ────\n\n'
                'CHỌN ẢNH AVATAR\n\n\n'
                '[icon] Chụp ảnh\n\n'
                '─────────────\n\n'
                '[icon] Chọn từ thư viện',
                S_MODAL + 'align=left;spacingLeft=30;spacingTop=15;',
                PHONE_X, PHONE_Y + PHONE_H - 280, PHONE_W, 280)

    note(cells,
         'POPUP — Image Source (Bottom Sheet)\n\n'
         '- Trigger: tap nút camera trên avatar edit\n'
         '- showModalBottomSheet() slide từ dưới lên\n'
         '- 2 option:\n'
         '  · Chụp ảnh (ImageSource.camera)\n'
         '  · Chọn từ thư viện (ImageSource.gallery)\n'
         '- Xin permission camera/media trước khi mở',
         NOTE_X, cy + 300, NOTE_COL_W, 200, sheet)


# ============ Build XML ============

def build_diagram(name, builder):
    cells = []
    builder(cells)
    inner = '\n'.join(c.to_xml() for c in cells)
    diag_id = name.replace(' ', '_').replace('.', '').replace('—', '_')
    return f'''  <diagram id="{diag_id}" name="{name}">
    <mxGraphModel dx="1200" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1000" pageHeight="850" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
{inner}
      </root>
    </mxGraphModel>
  </diagram>'''


def main():
    diagrams = [build_diagram(name, fn) for name, fn in SCREENS]
    xml = ('<mxfile host="app.diagrams.net" '
           'agent="VocabQuest-exporter" version="22.1.2" type="device">\n'
           + '\n'.join(diagrams) + '\n</mxfile>')
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, 'w', encoding='utf-8') as f:
        f.write(xml)
    print(f'Saved: {OUT_PATH}')
    print(f'Pages: {len(SCREENS)}')


if __name__ == '__main__':
    main()
