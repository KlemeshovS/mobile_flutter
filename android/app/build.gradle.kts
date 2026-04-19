import java.io.FileInputStream
import java.util.*
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
	id("com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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
    jvmTarget = "17"
}

    defaultConfig {
        applicationId = "com.tritan.wobbly_flutter"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    	resValue("string", "google_web_client_id", "293241377764-4ipsi5achpqcsku9o6ug7vrh0shv60v8.apps.googleusercontent.com")
    	manifestPlaceholders["YANDEX_CLIENT_ID"] = "09e2a2750f4b4dd6af874c3adeaf1354"
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
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
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
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

dependencies {
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.22")
    	implementation("com.google.android.gms:play-services-auth:20.7.0")
 	implementation(platform("com.google.firebase:firebase-bom:34.11.0"))
   	implementation("com.google.firebase:firebase-analytics")
}