import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_layout.dart';
import '../data/repositories/settings_repository.dart';
import 'app_state.dart';

/// Масштаб интерфейса (§3.5).
///
/// Приложение меряет всё в логических точках, а сколько это миллиметров —
/// решает система. На 4K при 100 % масштабе Windows текст и кнопки выходят
/// физически вдвое мельче, чем на Full HD: раскладка та же, читать нечем.
enum UiScale {
  /// По ширине окна: широкому окну — крупнее. См. [AppLayout.scale].
  auto(null),
  s90(0.9),
  s100(1.0),
  s110(1.1),
  s125(1.25);

  const UiScale(this.factor);

  /// Множитель кегля; `null` — считать по ширине окна.
  final double? factor;

  static UiScale parse(String? raw) =>
      UiScale.values.where((v) => v.name == raw).firstOrNull ?? UiScale.auto;
}

/// Выбранный масштаб интерфейса. Хранится в таблице настроек.
final uiScaleProvider = NotifierProvider<UiScaleController, UiScale>(
  UiScaleController.new,
);

class UiScaleController extends Notifier<UiScale> {
  /// Значение уже определено — восстановлением или выбором человека.
  ///
  /// Чтение из базы асинхронное, и без этой отметки выбор, сделанный в первые
  /// кадры после запуска, затирался бы пришедшим следом старым значением.
  bool _settled = false;

  @override
  UiScale build() {
    // Значение подгружается асинхронно — как у темы и языка. До этого
    // действует «авто», то есть ровно то, что было до появления настройки.
    _restore();
    return UiScale.auto;
  }

  Future<void> _restore() async {
    final raw = await ref
        .read(settingsRepositoryProvider)
        .get(SettingKeys.uiScale);
    if (_settled) return;
    _settled = true;
    state = UiScale.parse(raw);
  }

  Future<void> set(UiScale value) async {
    _settled = true;
    state = value;
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingKeys.uiScale, value.name);
  }
}

/// Кегль, умноженный на масштаб интерфейса.
///
/// Не заменяет системный масштаб, а домножает его: Android 14 масштабирует
/// шрифт нелинейно — мелкий текст растёт сильнее крупного, — и подменять эту
/// кривую своей линейной значило бы спорить с системной настройкой доступности.
@immutable
class ScaledTextScaler extends TextScaler {
  const ScaledTextScaler(this.inner, this.factor);

  final TextScaler inner;
  final double factor;

  @override
  double scale(double fontSize) => inner.scale(fontSize * factor);

  // Устарел, но TextScaler всё ещё требует его реализовать: пока он в
  // интерфейсе, честнее домножить его так же, как и всё остальное.
  @Deprecated('Оставлен ради обязательного члена TextScaler')
  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => inner.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is ScaledTextScaler &&
      other.inner == inner &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(inner, factor);
}

/// Кегль приложения: масштаб интерфейса поверх системного, затем общий предел.
///
/// Порядок важен, поэтому обе части собраны здесь, а не расставлены по месту:
/// множитель стоит снаружи зажима, иначе системный «Огромный» шрифт вместе с
/// ручными 125 % дал бы 1.9, а такой размер не выдержит ни одна плотная
/// раскладка.
///
/// Крупный системный шрифт приложение держит: карточки и поля растут вместе
/// с ним. Но Android разрешает увеличивать текст вдвое — выше 1.5 не идём.
Widget appTextScaleBuilder(BuildContext context, Widget? child) => UiScaleScope(
  child: MediaQuery.withClampedTextScaling(maxScaleFactor: 1.5, child: child!),
);

/// Применяет масштаб интерфейса ко всему поддереву.
///
/// Отдельно от предела: сам по себе почти никогда не нужен — берите
/// [appTextScaleBuilder].
class UiScaleScope extends ConsumerWidget {
  const UiScaleScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factor =
        ref.watch(uiScaleProvider).factor ?? AppLayout.of(context).scale;
    if (factor == 1) return child;

    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: ScaledTextScaler(media.textScaler, factor),
      ),
      child: child,
    );
  }
}
