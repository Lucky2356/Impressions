/// Черновик формы быстрого добавления (§11).
///
/// Отдельно от виджета: правило «что считать пустым» и разбор сохранённого
/// проверяются без запуска интерфейса, а форма только раскладывает поля.
///
/// Фотографии в черновик не попадают намеренно: они занимают мегабайты и
/// хранятся в базе рядом с записями, а черновик — вещь временная. Об этом
/// сказано в самой форме.
class QuickAddDraft {
  const QuickAddDraft({
    this.title = '',
    this.note = '',
    this.typeId,
    this.typePicked = false,
    this.categoryId,
    this.relation,
    this.rating,
    this.showDetails = false,
    this.barcode,
    this.creator,
    this.customValues = const {},
    this.impressionDate,
    this.tags = const [],
    this.collectionId,
  });

  final String title;
  final String note;
  final String? typeId;

  /// Тип выбран человеком, а не подставлен по категории.
  final bool typePicked;

  final String? categoryId;
  final String? relation;
  final double? rating;
  final bool showDetails;
  final String? barcode;
  final String? creator;
  final Map<String, String> customValues;
  final DateTime? impressionDate;
  final List<String> tags;
  final String? collectionId;

  /// Восстанавливать нечего.
  ///
  /// Подставленный тип и раскрытые подробности за содержимое не считаются: их
  /// форма выставляет сама, и черновик из одного этого предлагать нелепо.
  bool get isEmpty =>
      title.trim().isEmpty &&
      note.trim().isEmpty &&
      categoryId == null &&
      relation == null &&
      rating == null &&
      barcode == null &&
      creator == null &&
      impressionDate == null &&
      tags.isEmpty &&
      collectionId == null &&
      customValues.values.every((v) => v.trim().isEmpty);

  Map<String, Object?> toJson() => {
    'title': title,
    'note': note,
    'typeId': typeId,
    'typePicked': typePicked,
    'categoryId': categoryId,
    'relation': relation,
    'rating': rating,
    'showDetails': showDetails,
    'barcode': barcode,
    'creator': creator,
    'customValues': customValues,
    'impressionDate': impressionDate?.toIso8601String(),
    'tags': tags,
    'collectionId': collectionId,
  };

  /// Разбирает сохранённое, не доверяя типам.
  ///
  /// Черновик мог записать прошлая версия формы: непонятное поле пропускается,
  /// а не роняет открытие формы.
  static QuickAddDraft fromJson(Map<String, Object?> json) {
    String? text(String key) {
      final value = json[key];
      return value is String && value.isNotEmpty ? value : null;
    }

    final date = text('impressionDate');
    return QuickAddDraft(
      title: text('title') ?? '',
      note: text('note') ?? '',
      typeId: text('typeId'),
      typePicked: json['typePicked'] == true,
      categoryId: text('categoryId'),
      relation: text('relation'),
      rating: switch (json['rating']) {
        final num value => value.toDouble(),
        _ => null,
      },
      showDetails: json['showDetails'] == true,
      barcode: text('barcode'),
      creator: text('creator'),
      customValues: switch (json['customValues']) {
        final Map<String, Object?> map => {
          for (final e in map.entries)
            if (e.value is String) e.key: e.value! as String,
        },
        _ => const {},
      },
      impressionDate: date == null ? null : DateTime.tryParse(date),
      tags: switch (json['tags']) {
        final List<Object?> list => [
          for (final item in list)
            if (item is String) item,
        ],
        _ => const [],
      },
      collectionId: text('collectionId'),
    );
  }
}
