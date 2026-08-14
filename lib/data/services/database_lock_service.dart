import 'package:path_provider/path_provider.dart';

import '../db/connection.dart';
import '../db/database_cipher.dart';
import 'secret_storage.dart';

/// Чем встречает запуск: открытой базой, запомненным ключом или вопросом.
enum LockStatus {
  /// Шифрование не включено — работаем как раньше.
  open,

  /// База зашифрована, ключ лежал в хранилище системы и уже подошёл.
  unlocked,

  /// База зашифрована, нужен пароль.
  needsPassword,

  /// База зашифрована, а ключ из хранилища к ней не подошёл.
  ///
  /// Так выглядит восстановление копии, сделанной под другим паролем: файл
  /// заменили, а запомненный ключ остался от прежней базы.
  staleKey,
}

/// Отпирание базы при запуске (§32).
///
/// Пароль нигде не сохраняется. «Помнить на этом устройстве» кладёт в
/// хранилище операционной системы выведенный из него ключ — на Windows он
/// зашифрован DPAPI на вашу учётную запись, на Android лежит в приватном
/// каталоге приложения и не попадает в копии.
class DatabaseLockService {
  const DatabaseLockService({this.secrets = const SecretStorage()});

  final SecretStorage secrets;

  /// Имя ключа в хранилище системы.
  static const String secretName = 'database_key';

  Future<DatabaseCipher> cipher() async =>
      DatabaseCipher((await getApplicationSupportDirectory()).path);

  /// Смотрит, нужен ли пароль, и по возможности открывает базу сама.
  ///
  /// Вызывается до первого обращения к данным: ключ должен стоять раньше,
  /// чем drift откроет файл.
  Future<LockStatus> prepare() async {
    final cipher = await this.cipher();
    final state = await cipher.readState();
    if (!state.encrypted) {
      databaseKey = null;
      return LockStatus.open;
    }

    final remembered = DatabaseCipher.decodeKey(await secrets.read(secretName));
    if (remembered == null) return LockStatus.needsPassword;

    if (!await cipher.verify(remembered)) {
      // Ключ не от этой базы: держать его дальше незачем, а человеку надо
      // дать ввести пароль от того файла, который лежит сейчас.
      await secrets.delete(secretName);
      return LockStatus.staleKey;
    }

    databaseKey = remembered;
    return LockStatus.unlocked;
  }

  /// Отпирает базу паролем. Возвращает false, если пароль не подошёл.
  Future<bool> unlock(String password, {bool remember = false}) async {
    final cipher = await this.cipher();
    final state = await cipher.readState();
    if (!state.encrypted) return true;

    final key = await DatabaseCipher.deriveKey(password, state.salt);
    if (!await cipher.verify(key)) return false;

    databaseKey = key;
    if (remember) {
      await secrets.write(secretName, DatabaseCipher.encodeKey(key));
    }
    return true;
  }

  /// Запоминает ключ нынешнего сеанса или забывает его.
  Future<void> remember(List<int> key) =>
      secrets.write(secretName, DatabaseCipher.encodeKey(key));

  Future<void> forget() => secrets.delete(secretName);

  Future<bool> isRemembered() async =>
      DatabaseCipher.decodeKey(await secrets.read(secretName)) != null;
}
