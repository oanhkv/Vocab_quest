plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin phai dat SAU Android va Kotlin plugin
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin cho Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.apptienganh.vocab_quest"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Cho phep dung Java 8+ APIs tren Android cu (bat buoc cho firebase_auth)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Application ID - khop voi Firebase project
        applicationId = "com.apptienganh.vocab_quest"
        // Firebase Auth can minSdk >= 23
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Bat buoc cho Firebase
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Tam thoi dung signing config cua debug de `flutter run --release` chay duoc
            // Production that su thi can tao keystore rieng
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Desugaring - can thiet cho firebase_auth tren Android cu
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase BOM - quan ly version cua cac SDK Firebase tu dong
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))

    // MultiDex - cho phep app co > 64K methods (bat buoc khi dung Firebase)
    implementation("androidx.multidex:multidex:2.0.1")
}
