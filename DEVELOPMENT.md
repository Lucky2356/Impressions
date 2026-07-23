# Разработка

## Требования

- Flutter stable 3.44+ (в этом проекте установлен в `C:\src\flutter`).
- Dart 3.12+ (идёт с Flutter).
- Android SDK (из Android Studio) — для Android-сборки.
- Visual Studio с рабочей нагрузкой «Desktop development with C++» — для Windows-сборки.
- Windows: включённый **Developer Mode** (для симлинков плагинов при сборке/запуске).

## Скрипты (PowerShell, папка `scripts/`)

| Скрипт | Действие |
| --- | --- |
| `bootstrap.ps1` | `flutter pub get` + генерация кода |
| `generate.ps1` | кодогенерация (build_runner + gen-l10n) |
| `check.ps1` | pub get → генерация → проверка формата → analyze → тесты (ненулевой код при ошибке) |
| `test.ps1` | все тесты |
| `build_windows.ps1` | сборка Windows release |
| `build_android.ps1` | сборка Android APK |

## Кодогенерация

Проект использует Drift, Freezed, json_serializable и gen-l10n. После изменения аннотированных классов, таблиц или `.arb`:

```powershell
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

## Структура

```
lib/
  app/            корневой App, роутинг (GoRouter), провайдер темы
  core/
    config/       app_config.dart — имя приложения и расширение файла
    theme/        токены, темы, типографика
    l10n/         arb/ (исходные строки) + gen/ (сгенерированный код)
    utils/        нормализация строк, хеши, uuid
  design_system/  переиспользуемые компоненты + debug-галерея
  data/
    db/           таблицы Drift, DAO, миграции
    repositories/ репозитории
    import_export/ контейнер .impressions, подпись, безопасный импорт
    backup/       резервные копии
  features/       экраны по разделам
test/             unit, db, widget, golden
```

## Соглашения

- Все строки UI — через `AppLocalizations` (никаких хардкод-строк в виджетах).
- Имя приложения и расширение файла — только в `AppConfig`.
- Изменяемые сущности версионируются через revisions; импорт не перезаписывает данные напрямую.
- Тяжёлые операции — в isolates; списки виртуализированы.
