plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.oil_distribution_app"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // =========================================================
    // Java 17 + Core Library Desugaring
    // مطلوب لـ flutter_local_notifications
    // =========================================================
    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.oil_distribution_app"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // حالياً نستخدم Debug signing
            // ويمكن تغييره لاحقاً عند تجهيز التطبيق للنشر
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// =========================================================
// Kotlin
// =========================================================

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// =========================================================
// Desugaring
// =========================================================

dependencies {
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )
}

// =========================================================
// Flutter
// =========================================================

flutter {
    source = "../.."
}