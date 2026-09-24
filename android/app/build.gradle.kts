import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // Firebase (google-services.json). Su version se declara en settings.gradle.kts.
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firma de release: los valores viven en key.properties (ignorado por git).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.jhc_sistemas.entregas"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Lo exige flutter_local_notifications (usa java.time en APIs antiguas).
        isCoreLibraryDesugaringEnabled = true
    }

    sourceSets["main"].java.srcDirs("src/main/kotlin")

    defaultConfig {
        applicationId = "com.jhc_sistemas.entregas"
        minSdk = flutter.minSdkVersion
        // 36 = ultima API estable, igual que el valor por defecto de Flutter.
        // AGP 9 lo marca como deprecado (se elimina en AGP 10): la forma nueva
        // seria targetSdk { version = release(36) }.
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        // maybeCreate no falla si AGP ya definio una configuracion "release".
        maybeCreate("release").apply {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    implementation(platform("com.google.firebase:firebase-bom:30.3.2"))
    implementation("com.google.firebase:firebase-analytics")

    implementation("androidx.multidex:multidex:2.0.1")

    // El plugin de Flutter espera estas versiones de Stripe; sin el pin la
    // resolucion puede traer una incompatible.
    constraints {
        implementation("com.stripe:stripe-android") {
            version { strictly("20.11.0") }
        }
        implementation("com.stripe:financial-connections") {
            version { strictly("20.11.0") }
        }
    }
}
