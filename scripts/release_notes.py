"""Описание релиза из CHANGELOG.md.

Текст выпуска и запись в истории изменений — это один и тот же текст, поэтому
он не пишется дважды. Скрипт берёт раздел нужной версии, поднимает заголовки на
уровень выше (в релизе нет заголовка самой версии — её видно в названии) и
разворачивает списки в абзацы: в changelog изменения перечислены, а на странице
выпуска читаются подряд.

Запуск: python3 scripts/release_notes.py 1.22.0 > notes.md
"""

import io
import os
import sys

REPO = "https://github.com/Lucky2356/Impressions"

INSTALL = """## Установка

**Windows** — `Impressions-{v}-windows-x64-setup.exe`. Права администратора не нужны, данные при удалении остаются.

**Android** — `Impressions-{v}.apk`, разрешите установку из неизвестных источников. Обновление поверх прошлой версии сохраняет все записи, если выше не сказано иное.

Полный список изменений — в [CHANGELOG.md]({repo}/blob/main/CHANGELOG.md).
"""


def section(changelog, version):
    """Строки раздела версии, без его собственного заголовка."""
    head = "## [" + version + "]"
    lines = changelog.splitlines()
    start = None
    for i, line in enumerate(lines):
        if line.startswith(head):
            start = i + 1
            break
    if start is None:
        sys.exit("В CHANGELOG.md нет раздела " + head)
    end = len(lines)
    for i in range(start, len(lines)):
        if lines[i].startswith("## ["):
            end = i
            break
    return lines[start:end]


def to_notes(lines):
    out = []
    for line in lines:
        if line.startswith("### "):
            line = line[1:]
        elif line.startswith("- "):
            # Пункт списка становится абзацем: пустая строка перед ним, если
            # предыдущий абзац её ещё не поставил.
            line = line[2:]
            if out and out[-1].strip():
                out.append("")
        out.append(line)
    return "\n".join(out).strip()


def main():
    if len(sys.argv) != 2:
        sys.exit("Использование: release_notes.py <версия>")
    version = sys.argv[1]
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    with io.open(os.path.join(root, "CHANGELOG.md"), encoding="utf-8") as f:
        changelog = f.read()
    body = to_notes(section(changelog, version))
    text = body + "\n\n" + INSTALL.format(v=version, repo=REPO)
    # Явные байты: кодировка stdout зависит от системы, а текст русский.
    sys.stdout.buffer.write(text.encode("utf-8"))


if __name__ == "__main__":
    main()
