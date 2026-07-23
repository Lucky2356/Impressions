"""Рисует значок приложения: раскрытая книга с закладкой на оранжевом фоне.

Значок собирается кодом, а не хранится картинкой, чтобы его можно было
пересобрать в любом размере без потери качества и без внешнего редактора.
Запуск: python scripts/make_icon.py
"""

import os
from PIL import Image, ImageDraw

# Фирменный оранжевый приложения (accentPrimary) и его тёмный край.
ORANGE = (245, 130, 43)
ORANGE_DARK = (214, 99, 20)
PAPER = (255, 255, 255)
PAPER_SHADE = (232, 234, 238)
BOOKMARK = (91, 141, 239)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
S = 1024  # рабочий размер, всё считается в долях от него


def rounded_background(draw, size, radius_ratio=0.22):
    """Скруглённый квадрат с вертикальным градиентом."""
    grad = Image.new("RGB", (1, size))
    for y in range(size):
        t = y / max(size - 1, 1)
        grad.putpixel(
            (0, y),
            tuple(
                int(ORANGE[i] + (ORANGE_DARK[i] - ORANGE[i]) * t) for i in range(3)
            ),
        )
    grad = grad.resize((size, size))

    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, size - 1, size - 1], radius=int(size * radius_ratio), fill=255
    )
    return grad, mask


def draw_book(draw, size, inset=0.0):
    """Раскрытая книга: две страницы с изгибом и закладка.

    `inset` сжимает рисунок к центру — для адаптивного значка Android, где
    система обрезает края под свою форму.
    """
    k = size / 1024.0
    cx = size / 2

    def p(x, y):
        """Точка в координатах 1024×1024 со сжатием к центру."""
        px, py = x * k, y * k
        return (cx + (px - cx) * (1 - inset), cx + (py - cx) * (1 - inset))

    # Левая страница.
    draw.polygon(
        [p(160, 330), p(500, 400), p(500, 790), p(160, 720)],
        fill=PAPER,
    )
    # Правая страница — чуть темнее, чтобы был виден разворот.
    draw.polygon(
        [p(864, 330), p(524, 400), p(524, 790), p(864, 720)],
        fill=PAPER_SHADE,
    )
    # Корешок.
    draw.polygon([p(500, 400), p(524, 400), p(524, 790), p(500, 790)], fill=ORANGE_DARK)

    # Строки текста на левой странице.
    for i, y in enumerate((470, 545, 620)):
        draw.line(
            [p(230, y), p(430 - i * 30, y + 12)],
            fill=PAPER_SHADE,
            width=max(int(18 * k), 2),
        )

    # Закладка: свисает с верхнего края правой страницы.
    draw.polygon(
        [p(680, 355), p(790, 377), p(790, 640), p(735, 585), p(680, 618)],
        fill=BOOKMARK,
    )


def render(size, inset=0.0, background=True, radius_ratio=0.22):
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    if background:
        grad, mask = rounded_background(None, S, radius_ratio)
        img.paste(grad, (0, 0), mask)
    draw_book(ImageDraw.Draw(img), S, inset)
    return img.resize((size, size), Image.LANCZOS)


def write(path, image):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    image.save(path)
    print("  ", os.path.relpath(path, ROOT))


def main():
    print("Android:")
    # Обычный значок.
    for folder, px in (
        ("mipmap-mdpi", 48),
        ("mipmap-hdpi", 72),
        ("mipmap-xhdpi", 96),
        ("mipmap-xxhdpi", 144),
        ("mipmap-xxxhdpi", 192),
    ):
        write(
            os.path.join(ROOT, "android/app/src/main/res", folder, "ic_launcher.png"),
            render(px),
        )
        # Передний слой адаптивного значка: система сама обрежет его по своей
        # форме, поэтому рисунок сжат к центру и без фона.
        write(
            os.path.join(
                ROOT, "android/app/src/main/res", folder, "ic_launcher_foreground.png"
            ),
            render(int(px * 2.2), inset=0.42, background=False),
        )

    print("Windows:")
    ico = os.path.join(ROOT, "windows/runner/resources/app_icon.ico")
    render(256).save(
        ico,
        sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
    )
    print("  ", os.path.relpath(ico, ROOT))

    print("Изображения приложения и витрины:")
    write(os.path.join(ROOT, "assets/icon/app_icon.png"), render(512))
    write(os.path.join(ROOT, "docs/screenshots/icon.png"), render(256))


if __name__ == "__main__":
    main()
