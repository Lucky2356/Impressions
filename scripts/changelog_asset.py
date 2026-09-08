"""Свежая часть CHANGELOG.md для сборки.

В приложение едет не вся история, а несколько последних разделов. Полная лежит
в корне репозитория и на GitHub; приложению из неё нужен раздел текущей версии —
его показывает окно «Что нового» после обновления и кнопка в настройках. К
1.22.0 файл дорос до 156 КБ: в семь раз больше значка приложения и пятая часть
от шрифта, и растёт он с каждым выпуском.

Запуск: python3 scripts/changelog_asset.py

Тот же формат разделов разбирают ещё в двух местах: release_notes.py собирает
из него описание выпуска, ChangelogService — окно «Что нового». Здесь нужны
границы разделов, а не тело одного, поэтому разбор свой; менять формат
заголовка придётся во всех трёх.

Файл получается сгенерированным и лежит в репозитории, как и остальное
сгенерированное. Забыть пересобрать его нельзя молча: тест
`test/unit/changelog_test.dart` требует, чтобы раздел версии из pubspec.yaml в
нём был.
"""

import io
import os
import sys

# Сколько последних разделов оставить. Приложению хватило бы одного — текущей
# версии, — но запас на «что изменилось с вашей версии» стоит пару килобайт.
KEEP = 5

OUTPUT = os.path.join("assets", "changelog.md")


def head(lines):
    """Номера строк с заголовками версий: `## [1.22.0] — 2026-08-27`."""
    return [i for i, line in enumerate(lines) if line.startswith("## [")]


def recent(changelog, keep=KEEP):
    """Преамбула файла и первые `keep` разделов."""
    lines = changelog.splitlines()
    starts = head(lines)
    if not starts:
        sys.exit("В CHANGELOG.md нет ни одного раздела версии")
    end = starts[keep] if len(starts) > keep else len(lines)
    return "\n".join(lines[:end]).rstrip() + "\n"


def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    with io.open(os.path.join(root, "CHANGELOG.md"), encoding="utf-8") as f:
        changelog = f.read()

    text = recent(changelog)
    path = os.path.join(root, OUTPUT)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with io.open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)

    full = len(changelog.encode("utf-8"))
    part = len(text.encode("utf-8"))
    print("{}: {} КБ из {} КБ".format(OUTPUT, part // 1024, full // 1024))


if __name__ == "__main__":
    main()
