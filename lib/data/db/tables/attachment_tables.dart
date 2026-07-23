import 'package:drift/drift.dart';

/// Вложения (§16): метаданные файлов на диске (не BLOB). Дедупликация по
/// SHA-256.
@DataClassName('AttachmentRow')
class Attachments extends Table {
  TextColumn get id => text()();

  /// SHA-256 содержимого — уникален (дедупликация).
  TextColumn get sha256 => text()();

  /// Относительный путь файла в хранилище приложения (не исходный путь).
  TextColumn get storagePath => text()();
  TextColumn get thumbPath => text().nullable()();
  TextColumn get mimeType => text()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get byteSize => integer()();
  TextColumn get caption => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {sha256},
  ];
}

/// Связь revision↔вложение (какие изображения относятся к версии сущности).
@DataClassName('RevisionAttachmentRow')
class RevisionAttachments extends Table {
  TextColumn get id => text()();

  /// Тип сущности: object | entry | profile | collection.
  TextColumn get entityKind => text()();
  TextColumn get revisionId => text()();
  TextColumn get attachmentId =>
      text().references(Attachments, #id, onDelete: KeyAction.restrict)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
