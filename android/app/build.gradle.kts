import java.util.Properties
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    
}

val keystoreFile = File(rootDir, "key.properties")
val keystoreProperties = Properties().apply {
    if (keystoreFile.exists()) {
        load(keystoreFile.inputStream())
    }
}
val hasReleaseKeystore = keystoreProperties.isNotEmpty()

android {
    namespace = "com.handloombazar.shop"
    compileSdk = 36
    ndkVersion = "28.0.13004108"

    compileOptions {
        // Enable core library desugaring and align with plugin Java target.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.handloombazar.shop"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        multiDexKeepProguard = file("multidex-config.pro")
        manifestPlaceholders["applicationName"] = "com.handloombazar.shop.MainApplication"
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                val configuredStoreFile = File(keystoreProperties["storeFile"] as String)
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = if (configuredStoreFile.isAbsolute) {
                    configuredStoreFile
                } else {
                    File(rootDir, configuredStoreFile.path)
                }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // Keep local release APKs installable on physical devices when no
                // dedicated release keystore is configured in the workspace.
                logger.warn("Release keystore not found. Falling back to the debug signing key for local installs.")
                signingConfigs.getByName("debug")
            }
            // Completely disable obfuscation to prevent crashes
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = false
            isJniDebuggable = false
            isRenderscriptDebuggable = false

            // Remove proguard files to prevent any obfuscation
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
    }

    applicationVariants.all {
        outputs.all {
            val outputImpl = this as? com.android.build.gradle.internal.api.ApkVariantOutputImpl
            outputImpl?.outputFileName = "handloombazar-user-app-v${defaultConfig.versionName}+${defaultConfig.versionCode}-${name}.apk"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")

    // Updated Firebase dependencies
    implementation(platform("com.google.firebase:firebase-bom:33.6.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    // Updated Google Play services auth
    implementation("com.google.android.gms:play-services-auth:20.7.0")

    // Enable core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
