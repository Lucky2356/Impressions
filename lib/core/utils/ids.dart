import 'package:uuid/uuid.dart';

/// Генерация идентификаторов. Все сущности используют UUID v4 (§17).
class Ids {
  const Ids._();

  static const _uuid = Uuid();

  static String newId() => _uuid.v4();
}
