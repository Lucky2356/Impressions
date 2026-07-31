import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// Черновики форм (§11).
///
/// Форма добавления живёт в модальном окне и никуда не сохраняется до нажатия
/// «Сохранить». На телефоне этого достаточно, чтобы потерять всё набранное:
/// Android спокойно выгружает приложение, пока человек выбирает фотографию в
/// галерее или отвечает на звонок.
///
/// Черновик — один на профиль и вид формы: смысла копить их нет, нужен ровно
/// тот, что человек не дописал.
class DraftRepository {
  DraftRepository(this.db);

  final AppDatabase db;

  /// Форма быстрого добавления записи.
  static const String quickAddKind = 'quickAdd';

  static String _idFor(String profileId, String kind) => '$profileId:$kind';

  /// Черновик или null, если его нет либо он записан несовместимо.
  Future<Map<String, Object?>?> read(String profileId, String kind) async {
    final row = await (db.select(
      db.drafts,
    )..where((d) => d.id.equals(_idFor(profileId, kind)))).getSingleOrNull();
    if (row == null) return null;
    try {
      final decoded = jsonDecode(row.payloadJson);
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      // Черновик записан прошлой версией и не читается — не повод падать при
      // открытии формы. Он будет перезаписан первым же изменением.
      return null;
    }
  }

  Future<void> write(
    String profileId,
    String kind,
    Map<String, Object?> payload,
  ) async {
    await db
        .into(db.drafts)
        .insertOnConflictUpdate(
          DraftsCompanion.insert(
            id: _idFor(profileId, kind),
            profileId: Value(profileId),
            kind: kind,
            payloadJson: jsonEncode(payload),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> clear(String profileId, String kind) async {
    await (db.delete(
      db.drafts,
    )..where((d) => d.id.equals(_idFor(profileId, kind)))).go();
  }
}
