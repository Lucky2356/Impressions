import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Ключ подписи и пароли лежат вне репозитория: android/key.properties.
// Как его завести — в README, раздел «Ключ подписи Android».
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystore = keystorePropertiesFile.exists()
val keystoreProperties = Properties().apply {
    if (hasKeystore) FileInputStream(keystorePropertiesFile).use { load(it) }
}

// Собирать релиз отладочным ключом нельзя. Такой ключ одинаков у всех и лежит
// с общеизвестным паролем: пересборка на другой машине даёт другую подпись,
// Android отказывается обновлять приложение, и данные приходится терять
// вместе с ним. Поэтому отсутствие ключа — ошибка сборки, а не тихий откат.
gradle.taskGraph.whenReady {
    if (!hasKeystore && allTasks.any { it.name.contains("Release") }) {
        throw GradleException(
            "Нет android/key.properties — релизную сборку нечем подписать. " +
                "Отладочный ключ для выпуска не годится: см. README, " +
                "раздел «Ключ подписи Android»."
        )
    }
}

android {
    namespace = "club.impressions.impressions"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "club.impressions.impressions"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Приложение ставят файлом с GitHub, а не из магазина, поэтому в APK едут
    // все архитектуры сразу — и весит он втрое больше нужного: 89,6 МБ, из них
    // 86,5 нативные библиотеки. x86_64 из них 31,6 МБ, а живёт эта архитектура
    // только в эмуляторах: телефону нужна одна из двух оставшихся.
    //
    // Выбрасывается при упаковке, а не через `ndk.abiFilters`: фильтр не
    // касается библиотек из чужих AAR, и сканер штрихкодов приезжал в x86_64
    // всё равно — 5,6 МБ, которые никто никогда не запустит.
    //
    // Отладочные сборки это тоже касается. Чтобы запустить приложение в
    // эмуляторе, строку придётся временно убрать.
    packaging {
        jniLibs {
            excludes += "lib/x86_64/**"
        }
    }

    signingConfigs {
        if (hasKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                // Путь считается от каталога android/ — там же, где лежит
                // key.properties. Обычный file() отсчитывал бы от android/app/,
                // и ключ рядом с key.properties просто не нашёлся бы.
                storeFile = keystoreProperties
                    .getProperty("storeFile")
                    ?.let { rootProject.file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasKeystore) signingConfigs.getByName("release") else null
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
