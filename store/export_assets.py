from PIL import Image
from pathlib import Path

src = Path(r"C:\Users\facu\.cursor\projects\d-Juegos-One\assets")
out = Path(r"d:\Juegos\One\one_more_try\store")
out.mkdir(parents=True, exist_ok=True)
(out / "source").mkdir(exist_ok=True)


def cover_resize(im: Image.Image, size: tuple[int, int]) -> Image.Image:
    tw, th = size
    sw, sh = im.size
    scale = max(tw / sw, th / sh)
    nw, nh = int(sw * scale), int(sh * scale)
    im2 = im.resize((nw, nh), Image.Resampling.LANCZOS)
    left = (nw - tw) // 2
    top = (nh - th) // 2
    return im2.crop((left, top, left + tw, top + th))


# Feature graphic exact Play size
fg = Image.open(src / "feature_graphic_source.png").convert("RGB")
cover_resize(fg, (1024, 500)).save(out / "feature-graphic-1024x500.png", optimize=True)
print("feature graphic ok")

shots = [
    ("shot_home_source.png", "screenshot-01-home.png"),
    ("shot_gameplay_source.png", "screenshot-02-gameplay.png"),
    ("shot_result_source.png", "screenshot-03-result.png"),
    ("shot_skins_source.png", "screenshot-04-skins.png"),
]

for src_name, dst_name in shots:
    im = Image.open(src / src_name).convert("RGB")
    cover_resize(im, (1080, 1920)).save(out / dst_name, optimize=True)
    print("saved", dst_name)
    Image.open(src / src_name).convert("RGB").save(out / "source" / src_name, optimize=True)

fg.save(out / "source" / "feature_graphic_source.png", optimize=True)

# High-res icon 512
icon_src = Path(r"d:\Juegos\One\one_more_try\assets\branding\app_icon.png")
icon = Image.open(icon_src).convert("RGBA")
icon = icon.resize((512, 512), Image.Resampling.LANCZOS)
bg = Image.new("RGB", (512, 512), (11, 13, 16))
bg.paste(icon, mask=icon.split()[-1])
bg.save(out / "icon-512.png", optimize=True)
print("icon 512 ok")

print("DONE")
for p in sorted(out.glob("*.png")):
    print(p.name, p.stat().st_size)
