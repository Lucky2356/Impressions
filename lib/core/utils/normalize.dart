/// Нормализация названий (§26). Используется для устойчивого сравнения
/// категорий, объектов и тегов независимо от регистра и пробелов.
class Normalize {
  const Normalize._();

  /// Базовая нормализация: обрезка, нижний регистр, схлопывание пробелов.
  /// Сохраняет буквы/цифры пользовательских названий любого языка.
  static String name(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Нормализация для поиска дублей: [name] + удаление пунктуации.
  /// «Папа Может, варёная!» → «папа может варёная».
  static String forMatch(String input) {
    final lowered = input.trim().toLowerCase();
    final noPunct = lowered.replaceAll(
      RegExp(r'''[^\p{L}\p{N}\s]''', unicode: true),
      ' ',
    );
    return noPunct.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
