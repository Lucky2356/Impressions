import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Откуда приложение берёт изображения (§16).
///
/// На Windows это выбор файла и перетаскивание, на Android — галерея и камера.
/// Вынесено отдельно, потому что снимки выбирают в двух местах: в карточке
/// записи и в форме добавления. Раньше выбор был только в карточке, и фото
/// приходилось добавлять вторым заходом.
class PhotoSource {
  const PhotoSource._();

  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  static const _images = XTypeGroup(
    label: 'Изображения',
    extensions: ['jpg', 'jpeg', 'png', 'webp'],
  );

  /// Выбор одного или нескольких изображений подходящим для платформы способом.
  static Future<List<Uint8List>> pick() async {
    if (isDesktop) {
      final files = await openFiles(acceptedTypeGroups: const [_images]);
      return [for (final f in files) await f.readAsBytes()];
    }
    final files = await ImagePicker().pickMultiImage();
    return [for (final f in files) await f.readAsBytes()];
  }

  /// Снимок с камеры. На Windows камеры нет — вызывать неоткуда.
  static Future<Uint8List?> capture() async {
    final shot = await ImagePicker().pickImage(source: ImageSource.camera);
    return shot == null ? null : await shot.readAsBytes();
  }
}
