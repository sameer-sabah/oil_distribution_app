import java.util.Properties
import java.io.FileInputStream

// =========================================================
// تحميل بيانات مفتاح التوقيع
// =========================================================

val keystorePropertiesFile =
    rootProject.file("key.properties")

val keystoreProperties =
    Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(
        FileInputStream(keystorePropertiesFile)
    )
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.samir.nafithat"

    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    // =========================================================
    // Java 17 + Core Library Desugaring
    // =========================================================

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility =
            JavaVersion.VERSION_17

        targetCompatibility =
            JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId =
            "com.samir.nafithat"

        minSdk = flutter.minSdkVersion

        targetSdk = 36

        versionCode =
            flutter.versionCode

        versionName =
            flutter.versionName
    }

    // =========================================================
    // Release Signing
    // =========================================================

    signingConfigs {
        create("release") {
            keyAlias =
                keystoreProperties["keyAlias"] as String

            keyPassword =
                keystoreProperties["keyPassword"] as String

            storeFile =
                file(
                    keystoreProperties["storeFile"]
                            as String
                )

            storePassword =
                keystoreProperties["storePassword"]
                        as String
        }
    }

    // =========================================================
    // Build Types
    // =========================================================

    buildTypes {
        release {
            signingConfig =
                signingConfigs.getByName("release")

            isMinifyEnabled = false
            isShrinkResources = false
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
    implementation("androidx.annotation:annotation:1.9.1")
    compileOnly("io.flutter:flutter_embedding_debug:1.0.0-83675ed27633283e7fc296c8bca22e841224c096")
}

// =========================================================
// Flutter
// =========================================================

flutter {
    source = "../.."
}
