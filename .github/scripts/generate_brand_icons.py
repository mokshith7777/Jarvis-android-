#!/usr/bin/env python3
"""Generate Android legacy and adaptive launcher icon assets from the committed source PNG."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/branding/file_000000005a108211b9609ec55b3b26c4.png"
CLEAN = ROOT / "assets/branding/JARVIS_PRO_v3.3_Launcher_Icon_512.png"
RES = ROOT / "android/app/src/main/res"
DENSITIES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
ADAPTIVE = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}

if not SOURCE.exists():
    raise SystemExit(f"Missing launcher icon source: {SOURCE}")
icon = Image.open(SOURCE).convert("RGBA")
# Center-crop to square without stretching.
w, h = icon.size
side = min(w, h)
icon = icon.crop(((w-side)//2, (h-side)//2, (w-side)//2+side, (h-side)//2+side))
icon.save(CLEAN, "PNG")

for density, size in DENSITIES.items():
    folder = RES / f"mipmap-{density}"
    folder.mkdir(parents=True, exist_ok=True)
    icon.resize((size, size), Image.Resampling.LANCZOS).save(folder / "ic_launcher.png")
    bg = Image.new("RGBA", (size, size), (5, 5, 5, 255))
    bg.save(folder / "ic_launcher_background.png")
    fg_size = ADAPTIVE[density]
    fg = Image.new("RGBA", (fg_size, fg_size), (0, 0, 0, 0))
    inner = icon.resize((int(fg_size * .68), int(fg_size * .68)), Image.Resampling.LANCZOS)
    fg.alpha_composite(inner, ((fg_size-inner.width)//2, (fg_size-inner.height)//2))
    fg.save(folder / "ic_launcher_foreground.png")

print("Generated launcher icons in all Android densities.")
