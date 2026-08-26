"""Icon Composer 用にレイヤーを分割し、stroke をアウトライン化して書き出す。

出力はすべて 1024x1024 / 背景透過 / fill のみ (stroke 属性なし)。
"""
import math, os, subprocess, shutil, sys
from PIL import Image
from collections import deque

sys.setrecursionlimit(100000)

W_TRUNK, W_BRANCH = 42.0, 32.0
R_DOT, R_HALO = 40.0, 52.0
DOTS = [(584.0, 248.0), (577.0, 505.0)]
ART, DOT_C, BODY_C, BG = '#0E8F8A', '#B32620', '#FFFFFF', '#2D6A7B'

# 中心線 (build_icon.py と同一)
TRUNK = [(588, -30), (586, 240), (580, 430), (573, 600)]
ANT = [(573, 600), (553, 626), (536, 644), (524, 660), (508, 682), (505, 686), (492, 700),
       (478, 715), (469, 727), (455, 742), (441, 757), (427, 770), (412, 782),
       (402, 790), (392, 795), (382, 799)]
POST = [(573, 600), (587, 618), (594, 632), (598, 645), (608, 664), (615, 682), (618, 700),
        (624, 717), (627, 735), (628, 752), (630, 766), (623, 772), (612, 778),
        (598, 784), (578, 786), (560, 786), (552, 786), (546, 786), (540, 786)]


# ---------- 幾何ユーティリティ ----------
def flatten(pts, steps=90):
    """[P0,C1,C2,P1,C1,C2,P2,...] の連続キュービックを折れ線化"""
    out = []
    for s in range(0, len(pts) - 1, 3):
        p0, c1, c2, p1 = pts[s:s + 4]
        for i in range(steps + 1):
            t = i / steps; u = 1 - t
            out.append((u**3*p0[0] + 3*u*u*t*c1[0] + 3*u*t*t*c2[0] + t**3*p1[0],
                        u**3*p0[1] + 3*u*u*t*c1[1] + 3*u*t*t*c2[1] + t**3*p1[1]))
    d = [out[0]]
    for p in out[1:]:
        if math.dist(p, d[-1]) > 1e-7: d.append(p)
    return d


def arc(center, a0, a1, r, n=16):
    if a1 > a0: a1 -= 2 * math.pi          # y 下向き座標系では減少方向が前進側
    return [(center[0] + r*math.cos(a0 + (a1-a0)*i/n),
             center[1] + r*math.sin(a0 + (a1-a0)*i/n)) for i in range(n + 1)]


def circle_hit(p_out, p_in, c, r):
    """線分 p_out->p_in と円 (c, r) の交点"""
    dx, dy = p_in[0]-p_out[0], p_in[1]-p_out[1]
    fx, fy = p_out[0]-c[0], p_out[1]-c[1]
    a = dx*dx + dy*dy
    b = 2*(fx*dx + fy*dy)
    cc = fx*fx + fy*fy - r*r
    disc = b*b - 4*a*cc
    if disc < 0 or a == 0: return p_out
    t = (-b + math.sqrt(disc)) / (2*a)
    if not 0 <= t <= 1:
        t = (-b - math.sqrt(disc)) / (2*a)
    t = max(0.0, min(1.0, t))
    return (p_out[0] + dx*t, p_out[1] + dy*t)


def short_arc(c, p, q, n=14):
    """円 c 上を p から q へ短い側で回る点列"""
    r = math.dist(c, p)
    a0 = math.atan2(p[1]-c[1], p[0]-c[0])
    a1 = math.atan2(q[1]-c[1], q[0]-c[0])
    d = (a1 - a0 + math.pi) % (2*math.pi) - math.pi
    return [(c[0] + r*math.cos(a0 + d*i/n), c[1] + r*math.sin(a0 + d*i/n)) for i in range(1, n)]


def outline(poly, width, cut_start=None, cut_end=None):
    """折れ線を太らせて閉じた輪郭に (round cap / round join 相当)"""
    h = width / 2
    n = len(poly)
    nor = []
    for i in range(n):
        a = poly[max(i-1, 0)]; b = poly[min(i+1, n-1)]
        tx, ty = b[0]-a[0], b[1]-a[1]
        L = math.hypot(tx, ty) or 1e-9
        nor.append((-ty/L, tx/L))
    left  = [(poly[i][0] + nor[i][0]*h, poly[i][1] + nor[i][1]*h) for i in range(n)]
    right = [(poly[i][0] - nor[i][0]*h, poly[i][1] - nor[i][1]*h) for i in range(n)]
    a_end = math.atan2(left[-1][1]-poly[-1][1], left[-1][0]-poly[-1][0])
    b_end = math.atan2(right[-1][1]-poly[-1][1], right[-1][0]-poly[-1][0])
    a_beg = math.atan2(right[0][1]-poly[0][1], right[0][0]-poly[0][0])
    b_beg = math.atan2(left[0][1]-poly[0][1], left[0][0]-poly[0][0])
    if cut_end is None:
        cap_end = arc(poly[-1], a_end, b_end, h)
    else:
        c, r, nxt = cut_end
        le, re = circle_hit(left[-1], (nxt[0]+ (left[-1][0]-poly[-1][0]), nxt[1] + (left[-1][1]-poly[-1][1])), c, r), \
                 circle_hit(right[-1], (nxt[0]+ (right[-1][0]-poly[-1][0]), nxt[1] + (right[-1][1]-poly[-1][1])), c, r)
        cap_end = [le] + short_arc(c, le, re) + [re]
    if cut_start is None:
        cap_beg = arc(poly[0], a_beg, b_beg, h)
    else:
        c, r, prv = cut_start
        rb, lb = circle_hit(right[0], (prv[0] + (right[0][0]-poly[0][0]), prv[1] + (right[0][1]-poly[0][1])), c, r), \
                 circle_hit(left[0],  (prv[0] + (left[0][0]-poly[0][0]),  prv[1] + (left[0][1]-poly[0][1])),  c, r)
        cap_beg = [rb] + short_arc(c, rb, lb) + [lb]
    ring = left + cap_end + right[::-1] + cap_beg
    # 向きを揃える (nonzero での和集合を保証)
    area = sum(ring[i][0]*ring[(i+1) % len(ring)][1] - ring[(i+1) % len(ring)][0]*ring[i][1]
               for i in range(len(ring)))
    return ring if area > 0 else ring[::-1]


def rdp(pts, eps):
    if len(pts) < 3: return pts
    (x1, y1), (x2, y2) = pts[0], pts[-1]
    dx, dy = x2-x1, y2-y1
    nrm = math.hypot(dx, dy) or 1e-9
    dmax = 0.0; idx = 0
    for i in range(1, len(pts)-1):
        x, y = pts[i]
        d = abs(dy*x - dx*y + x2*y1 - y2*x1) / nrm
        if d > dmax: dmax, idx = d, i
    if dmax > eps:
        return rdp(pts[:idx+1], eps)[:-1] + rdp(pts[idx:], eps)
    return [pts[0], pts[-1]]


def closed_path(pts, a=0.5):
    """向心 Catmull-Rom で閉じたベジエパスに"""
    n = len(pts)
    dist = lambda p, q: max(math.dist(p, q), 1e-6) ** a
    out = ['M %.2f %.2f' % pts[0]]
    for i in range(n):
        p0, p1, p2, p3 = pts[(i-1) % n], pts[i], pts[(i+1) % n], pts[(i+2) % n]
        d1, d2, d3 = dist(p0, p1), dist(p1, p2), dist(p2, p3)
        b1 = []; b2 = []
        for k in (0, 1):
            b1.append((d1*d1*p2[k] - d2*d2*p0[k] + (2*d1*d1 + 3*d1*d2 + d2*d2)*p1[k]) / (3*d1*(d1+d2)))
            b2.append((d3*d3*p1[k] - d2*d2*p3[k] + (2*d3*d3 + 3*d3*d2 + d2*d2)*p2[k]) / (3*d3*(d3+d2)))
        out.append('C %.2f %.2f %.2f %.2f %.2f %.2f' % (b1[0], b1[1], b2[0], b2[1], p2[0], p2[1]))
    return ' '.join(out) + ' Z'


def stroke_to_path(pts, width, gaps=()):
    """中心線 -> 塗りパス。gaps=((cx,cy,r),...) の内側は描かない"""
    poly = flatten(pts)
    inside = [next(((gx, gy, gr) for gx, gy, gr in gaps
                    if math.dist(p, (gx, gy)) < gr), None) for p in poly]
    runs = []; cur = []
    for i, p in enumerate(poly):
        if inside[i] is not None:
            if len(cur) > 1: runs.append(cur)
            cur = []
        else:
            cur.append(i)
    if len(cur) > 1: runs.append(cur)
    ds = []
    for idx in runs:
        i0, i1 = idx[0], idx[-1]
        cs = ce = None
        if i0 > 0 and inside[i0-1]:
            g = inside[i0-1]; cs = ((g[0], g[1]), g[2], poly[i0-1])
        if i1 < len(poly)-1 and inside[i1+1]:
            g = inside[i1+1]; ce = ((g[0], g[1]), g[2], poly[i1+1])
        r = [poly[i] for i in idx]
        ring = outline(r, width, cs, ce)
        if math.dist(ring[0], ring[-1]) < 1e-6: ring = ring[:-1]
        h = len(ring) // 2          # 閉曲線は半分ずつ簡略化する (始点=終点で RDP が退化するため)
        simp = rdp(ring[:h+1], 0.12)[:-1] + rdp(ring[h:] + [ring[0]], 0.12)[:-1]
        # オフセット輪郭は直線で出力する。曲線近似で再フィットすると太さが揺らぐため
        ds.append('M ' + ' L '.join('%.2f %.2f' % p for p in simp) + ' Z')
    return ' '.join(ds)


def circle_path(cx, cy, r):
    k = 0.5522847498 * r
    return (f'M {cx:.2f} {cy-r:.2f} '
            f'C {cx+k:.2f} {cy-r:.2f} {cx+r:.2f} {cy-k:.2f} {cx+r:.2f} {cy:.2f} '
            f'C {cx+r:.2f} {cy+k:.2f} {cx+k:.2f} {cy+r:.2f} {cx:.2f} {cy+r:.2f} '
            f'C {cx-k:.2f} {cy+r:.2f} {cx-r:.2f} {cy+k:.2f} {cx-r:.2f} {cy:.2f} '
            f'C {cx-r:.2f} {cy-k:.2f} {cx-k:.2f} {cy-r:.2f} {cx:.2f} {cy-r:.2f} Z')


LEG = open('leg-path.txt').read()
EXT = [(417, -30), (438, 170), (716, 170), (737, -30)]


def signed_area(pts):
    return sum(pts[i][0]*pts[(i+1) % len(pts)][1] - pts[(i+1) % len(pts)][0]*pts[i][1]
               for i in range(len(pts)))


def limb_path():
    """元の輪郭パスと上端延長部を、同じ巻き方向の 2 サブパスとして結合 (nonzero で和集合)"""
    nums = [float(v) for v in LEG.replace('M', ' ').replace('C', ' ').replace('Z', ' ').split()]
    on_curve = [(nums[0], nums[1])] + [(nums[i+4], nums[i+5]) for i in range(0, len(nums)-6, 6)]
    ext = EXT if (signed_area(EXT) > 0) == (signed_area(on_curve) > 0) else EXT[::-1]
    d = ' L '.join('%g %g' % p for p in ext)
    return LEG + f' M {d} Z'


def trace_body():
    im = Image.open('bodymask.png').convert('L').resize((512, 512), Image.LANCZOS)
    px = im.load(); S = 512
    m = [[px[x, y] >= 128 for x in range(S)] for y in range(S)]
    start = next((x, y) for y in range(S) for x in range(S) if m[y][x])
    nb = [(1,0),(1,1),(0,1),(-1,1),(-1,0),(-1,-1),(0,-1),(1,-1)]
    get = lambda p: 0 <= p[0] < S and 0 <= p[1] < S and m[p[1]][p[0]]
    contour = [start]; cur = start; bd = 4
    for _ in range(300000):
        for k in range(8):
            d = (bd + 1 + k) % 8
            c = (cur[0] + nb[d][0], cur[1] + nb[d][1])
            if get(c):
                bd = (d + 5) % 8; cur = c; contour.append(cur); break
        else:
            break
        if cur == start and len(contour) > 10: break
    c = contour[:-1] if contour[0] == contour[-1] else contour
    h = len(c) // 2
    simp = rdp(c[:h+1], 1.0)[:-1] + rdp(c[h:] + [c[0]], 1.0)[:-1]
    return closed_path([(x*2.0, y*2.0) for x, y in simp])


def svg(body, opacity_note, *shapes):
    inner = '\n  '.join(shapes)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" '
            f'viewBox="0 0 1024 1024">\n  <!-- {opacity_note} -->\n  {inner}\n</svg>\n')


def main():
    gaps = tuple((x, y, R_HALO) for x, y in DOTS)
    limb = limb_path()
    artery = ' '.join([
        stroke_to_path(ANT,   W_BRANCH, gaps),
        stroke_to_path(POST,  W_BRANCH, gaps),
        stroke_to_path(TRUNK, W_TRUNK,  gaps),
    ])
    lesions = ' '.join(circle_path(x, y, R_DOT) for x, y in DOTS)

    files = {
        '1-Background.svg': svg(None, 'Layer 1 / background', f'<rect width="1024" height="1024" fill="{BG}"/>'),
        '2-Limb.svg':       svg(None, 'Layer 2 / limb',       f'<path fill-rule="nonzero" d="{limb}" fill="{BODY_C}"/>'),
        '3-Artery.svg':     svg(None, 'Layer 3 / artery',     f'<path fill-rule="nonzero" d="{artery}" fill="{ART}"/>'),
        '4-Lesions.svg':    svg(None, 'Layer 4 / lesions',    f'<path fill-rule="nonzero" d="{lesions}" fill="{DOT_C}"/>'),
    }
    os.makedirs('layers', exist_ok=True)
    for n, s in files.items():
        open('layers/' + n, 'w').write(s)
        print('%-18s %6d bytes' % (n, len(s)))

    # 検証用: 4 レイヤーを重ねた合成
    stack = svg(None, 'verify',
                f'<rect width="1024" height="1024" fill="{BG}"/>',
                f'<path fill-rule="nonzero" d="{limb}" fill="{BODY_C}"/>',
                f'<path fill-rule="nonzero" d="{artery}" fill="{ART}"/>',
                f'<path fill-rule="nonzero" d="{lesions}" fill="{DOT_C}"/>')
    open('layers-stacked.svg', 'w').write(stack)


if __name__ == '__main__':
    main()
