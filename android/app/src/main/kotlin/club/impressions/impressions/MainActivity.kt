package club.impressions.impressions

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * С чем приложение открыли: присланный файл или быстрое действие со значка.
 *
 * Раньше активность знала только LAUNCHER: файл обмена нельзя было ни открыть
 * из проводника, ни отправить в приложение через «Поделиться» — каждый раз
 * приходилось заходить в «Импорт» и искать файл вручную.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    /** Что пришло с запуском и ещё не забрано Flutter-стороной. */
    private var pendingFile: String? = null
    private var pendingAction: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    // Холодный старт: Flutter спрашивает сам, когда готов.
                    "consumeLaunch" -> {
                        result.success(
                            mapOf("file" to pendingFile, "action" to pendingAction),
                        )
                        pendingFile = null
                        pendingAction = null
                    }
                    else -> result.notImplemented()
                }
            }
        }

        readIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        readIntent(intent)
        // Приложение уже запущено — сообщаем сразу, ждать вопроса неоткуда.
        val file = pendingFile
        val action = pendingAction
        if (file != null || action != null) {
            channel?.invokeMethod(
                "launch",
                mapOf("file" to file, "action" to action),
            )
            pendingFile = null
            pendingAction = null
        }
    }

    private fun readIntent(intent: Intent?) {
        if (intent == null) return

        intent.getStringExtra(EXTRA_ACTION)?.let { pendingAction = it }

        val uri: Uri? = when (intent.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND -> if (Build.VERSION.SDK_INT >= 33) {
                intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(Intent.EXTRA_STREAM)
            }
            else -> null
        }
        if (uri != null) pendingFile = copyToCache(uri)
    }

    /**
     * Кладёт присланный файл в свой кеш и отдаёт путь к нему.
     *
     * Через `content://` Flutter-сторона читать не умеет, а разрешение на чужой
     * URI живёт только до конца обработки интента. Копия в кеше переживает и
     * перезапуск разбора.
     */
    private fun copyToCache(uri: Uri): String? {
        return try {
            val name = displayName(uri) ?: "shared"
            val dir = File(cacheDir, "incoming").apply { mkdirs() }
            val target = File(dir, name)
            contentResolver.openInputStream(uri)?.use { input ->
                target.outputStream().use { output -> input.copyTo(output) }
            } ?: return null
            target.absolutePath
        } catch (_: Exception) {
            // Файл недоступен или место кончилось: молча не открываем ничего —
            // сообщать об этом здесь некому, Flutter-сторона ещё не поднялась.
            null
        }
    }

    private fun displayName(uri: Uri): String? {
        if (uri.scheme == "file") return uri.lastPathSegment
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (index >= 0 && cursor.moveToFirst()) return cursor.getString(index)
        }
        return uri.lastPathSegment
    }

    companion object {
        const val CHANNEL = "club.impressions/launch"

        /** Ярлык на значке приложения кладёт сюда своё действие. */
        const val EXTRA_ACTION = "club.impressions.action"
    }
}
