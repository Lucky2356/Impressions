import 'package:flutter/material.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../data/services/file_delivery_service.dart';
import '../../design_system/design_system.dart';

/// Сказать человеку, чем кончилась выдача файла, и вернуть `true`, если файл
/// ушёл.
///
/// Выдача одна и та же для профиля, выгрузки «для чтения» и резервной копии, а
/// формулировки должны совпадать: «сохранён» на компьютере и «передан» на
/// телефоне — это про способ, а не про то, что именно унесли. Что делать после
/// удачи, решает вызывающий: диалог экспорта закрывается, настройки остаются
/// открытыми.
bool reportDelivery(BuildContext context, FileDelivery delivery) {
  final l10n = AppLocalizations.of(context);
  final message = switch (delivery.status) {
    FileDeliveryStatus.saved => l10n.fileSaved(delivery.path!),
    FileDeliveryStatus.shared => l10n.fileShared,
    FileDeliveryStatus.cancelled => l10n.fileSaveCancelled,
  };
  showMessage(context, message);
  return delivery.status != FileDeliveryStatus.cancelled;
}

/// Сказать, что выдача сорвалась. Молчать здесь нельзя: именно молчание и было
/// поломкой экспорта на Android.
void reportDeliveryFailure(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context);
  showMessage(context, l10n.fileSaveFailed('$error'));
}
