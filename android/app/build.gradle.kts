import java.io.FileInputStream
import java.util.*
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    throw GradleException("key.properties not found in android/ folder!")
}

android {
    namespace = "com.tritan.wobbly_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

defaultConfig {
    applicationId = "com.tritan.wobbly_flutter"
    minSdk = flutter.minSdkVersion
    targetSdk = 36
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}

    signingConfigs {
        create("release") {
            // Получаем значения и сразу проверяем на null
            val alias = keystoreProperties["keyAlias"]?.toString()
            val pwdKey = keystoreProperties["keyPassword"]?.toString()
            val pwdStore = keystoreProperties["storePassword"]?.toString()
            val filePath = keystoreProperties["storeFile"]?.toString()

            if (alias.isNullOrBlank()) throw GradleException("keyAlias missing or empty in key.properties")
            if (pwdKey.isNullOrBlank()) throw GradleException("keyPassword missing or empty in key.properties")
            if (pwdStore.isNullOrBlank()) throw GradleException("storePassword missing or empty in key.properties")
            if (filePath.isNullOrBlank()) throw GradleException("storeFile missing or empty in key.properties")

            keyAlias = alias
            keyPassword = pwdKey
            storePassword = pwdStore
            storeFile = file(filePath)
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
