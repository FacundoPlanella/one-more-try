plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.studio.onemoretry.one_more_try"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.studio.onemoretry.one_more_try"
        // google_mobile_ads requiere minSdk 23.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Firmando con claves debug para que `flutter run --release` funcione.
            // Reemplazar con tu signing config real antes de publicar (ver key.properties.example).
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // Provee los recursos appcompat (abc_*) que requieren google_mobile_ads y otros plugins.
    implementation("androidx.appcompat:appcompat:1.7.0")
}

flutter {
    source = "../.."
}
