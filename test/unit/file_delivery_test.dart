import 'dart:io';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impressions/data/services/file_delivery_service.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

/// Диалог сохранения ровно такой, какой он на Android: его нет.
///
/// `file_selector_android` реализует только открытие файла и выбор папки,
/// поэтому `getSaveLocation` уходит в заглушку платформенного слоя.
class _NoSaveDialog extends FileSelectorPlatform {}

/// Диалог сохранения настольной системы: отдаёт заранее известный путь.
class _DesktopSaveDialog extends FileSelectorPlatform {
  _DesktopSaveDialog(this.path);

  final String? path;
  String? askedName;

  @override
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions options = const SaveDialogOptions(),
  }) async {
    askedName = options.suggestedName;
    return path == null ? null : FileSaveLocation(path!);
  }
}

class _FakeShare extends SharePlatform {
  _FakeShare(this.status);

  final ShareResultStatus status;
  ShareParams? params;

  @override
  Future<ShareResult> share(ShareParams params) async {
    this.params = params;
    return ShareResult('fake', status);
  }
}

void main() {
  late Directory temp;
  late FileSelectorPlatform savedSelector;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('delivery');
    savedSelector = FileSelectorPlatform.instance;
  });

  tearDown(() {
    FileSelectorPlatform.instance = savedSelector;
    debugDefaultTargetPlatformOverride = null;
    if (temp.existsSync()) temp.deleteSync(recursive: true);
  });

  group('выдача файла на телефоне', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      // Именно этот диалог и ронял экспорт: без обхода вызов бросает
      // UnimplementedError и на телефоне не происходит ничего видимого.
      FileSelectorPlatform.instance = _NoSaveDialog();
    });

    test(
      'файл пишется и уходит в «Поделиться», а не в диалог сохранения',
      () async {
        final share = _FakeShare(ShareResultStatus.success);
        final service = FileDeliveryService(
          share: SharePlus.custom(share),
          stagingDirectory: temp,
        );

        final delivery = await service.deliver(
          fileName: 'Аня_2026.impressions',
          typeLabel: 'Впечатления',
          extension: 'impressions',
          write: (file) => file.writeAsBytes([1, 2, 3], flush: true),
        );

        expect(delivery.status, FileDeliveryStatus.shared);
        final shared = share.params!.files!.single.path;
        expect(p.basename(shared), 'Аня_2026.impressions');
        expect(File(shared).readAsBytesSync(), [1, 2, 3]);
      },
    );

    test('отказ от «Поделиться» — это отмена, а не сохранение', () async {
      final service = FileDeliveryService(
        share: SharePlus.custom(_FakeShare(ShareResultStatus.dismissed)),
        stagingDirectory: temp,
      );

      final delivery = await service.deliver(
        fileName: 'Аня.csv',
        typeLabel: 'CSV',
        extension: 'csv',
        write: (file) => file.writeAsString('x', flush: true),
      );

      expect(delivery.status, FileDeliveryStatus.cancelled);
    });

    test('прошлый файл не остаётся в папке передачи', () async {
      final service = FileDeliveryService(
        share: SharePlus.custom(_FakeShare(ShareResultStatus.success)),
        stagingDirectory: temp,
      );

      await service.deliver(
        fileName: 'Первый.csv',
        typeLabel: 'CSV',
        extension: 'csv',
        write: (file) => file.writeAsString('1', flush: true),
      );
      await service.deliver(
        fileName: 'Второй.csv',
        typeLabel: 'CSV',
        extension: 'csv',
        write: (file) => file.writeAsString('2', flush: true),
      );

      final left = Directory(
        p.join(temp.path, 'export'),
      ).listSync().map((e) => p.basename(e.path)).toList();
      expect(left, ['Второй.csv']);
    });
  });

  group('выдача файла на настольной системе', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.windows);

    test('файл пишется по выбранному пути', () async {
      final target = p.join(temp.path, 'Аня.impressions');
      final dialog = _DesktopSaveDialog(target);
      FileSelectorPlatform.instance = dialog;

      final delivery = await const FileDeliveryService().deliver(
        fileName: 'Аня.impressions',
        typeLabel: 'Впечатления',
        extension: 'impressions',
        write: (file) => file.writeAsBytes([7], flush: true),
      );

      expect(delivery.status, FileDeliveryStatus.saved);
      expect(delivery.path, target);
      expect(dialog.askedName, 'Аня.impressions');
      expect(File(target).readAsBytesSync(), [7]);
    });

    test('закрытый диалог ничего не пишет', () async {
      FileSelectorPlatform.instance = _DesktopSaveDialog(null);
      var wrote = false;

      final delivery = await const FileDeliveryService().deliver(
        fileName: 'Аня.impressions',
        typeLabel: 'Впечатления',
        extension: 'impressions',
        write: (file) async => wrote = true,
      );

      expect(delivery.status, FileDeliveryStatus.cancelled);
      expect(wrote, isFalse);
    });
  });
}
