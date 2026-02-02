plugins {
    id("com.android.application")
    id("kotlin-android") // keep existing version 1.8.22
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kericho_delivery"

    compileSdk = 36
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.kericho_delivery"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    buildFeatures {
        buildConfig = true
    }
}

flutter {
    source = "../.."
}
