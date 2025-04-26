plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin
    id("com.google.gms.google-services")    // Firebase services
}

android {
    namespace = "com.example.elimu_connect"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.elimu_connect"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11" // Matches Java 11
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug") // Replace with release signing later
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    implementation("com.google.firebase:firebase-firestore-ktx:24.10.0") // ✅ Recommended latest KTX version
    implementation("com.google.firebase:firebase-database-ktx:20.3.0")   // Optional, but use -ktx for Kotlin
    implementation("com.google.firebase:firebase-messaging-ktx:23.3.0")  // Optional messaging
}
