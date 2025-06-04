plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter debe aplicarse después de los plugins de Android y Kotlin:
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.meingel.onfocus.enfasisprogramacionmovil"
    // Usamos la misma versión de compileSdk que Flutter provee:
    compileSdk = flutter.compileSdkVersion

    // ─────────────────────────────────────────────────────────────────────────────
    // Forzamos la versión de NDK 27.0.12077973 (requerido por shared_preferences_android)
    ndkVersion = "27.0.12077973"
    // ─────────────────────────────────────────────────────────────────────────────

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Puedes mantener tu propio applicationId:
        applicationId = "com.meingel.onfocus.enfasisprogramacionmovil"
        // Flutter inyecta aquí las versiones mínimas y target desde su configuración:
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // Por el momento dejamos la configuración de firma de debug
            signingConfig = signingConfigs.getByName("debug")
            // Si deseas ofuscar/r8, aquí podrías habilitarlo:
            // isMinifyEnabled = true
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }
}

// Indica dónde está el directorio raíz de Flutter (../../ respecto a android/app)
flutter {
    source = "../.."
}