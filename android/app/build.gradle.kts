plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.pratik.doneit"
//    compileSdk = flutter.compileSdkVersion
    compileSdk = 35
//    ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973 "

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        /*   sourceCompatibility = JavaVersion.VERSION_11
           targetCompatibility = JavaVersion.VERSION_11*/

        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.pratik.doneit"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true

    }
    signingConfigs {
        create("release") {
            storeFile = file("key/upload-keystore.jks")
            storePassword = "@alphadoneit"
            keyAlias = "production"
            keyPassword = "@alphadoneit"
        }
    }
    buildTypes {
        release {
//            signingConfig signingConfigs.debug
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5") // Use the latest version
    // Add if your Flutter app crashes on Android 12L or later with desugaring
    implementation("androidx.window:window:1.4.0")
    implementation("androidx.window:window-java:1.4.0")
}

flutter {
    source = "../.."
}



