plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "com.example.praktik14"
    compileSdk = 36// Sesuaikan dengan SDK versi terbaru di IDE

    defaultConfig {
        applicationId = "com.example.praktik14"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    //tambahkan untuk mengaktifkan View Binding
    buildFeatures {
        viewBinding = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.activity)
    implementation(libs.androidx.constraintlayout)

    //mengambil lokasi GPS
    implementation("com.github.mumayank:AirLocation:2.5.2")
    //menampilkan peta OpenStreetMap
    implementation("org.osmdroid:osmdroid-android:6.1.20")
    implementation(libs.androidx.activity)
    implementation(libs.androidx.constraintlayout)

    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}