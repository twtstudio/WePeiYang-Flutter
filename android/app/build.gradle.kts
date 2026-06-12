import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.huawei.agconnect")
}

// 从 local.properties 读取版本号和签名信息
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { s -> localProperties.load(s) }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

val keystoreProps = Properties()
rootProject.file("local.properties").inputStream().use { s -> keystoreProps.load(s) }

// 打印构建信息
fun printTitledBox(title: String, content: List<String>, maxWidth: Int = 130) {
    val truncated = content.map { if (it.length > maxWidth) it.take(maxWidth - 3) + "..." else it }
    val maxLen = minOf(truncated.maxOfOrNull { it.length } ?: 0, maxWidth)
    val w = maxOf(maxLen, title.length) + 4
    val border = "+" + "-".repeat(w) + "+"
    println(border)
    println("| $title" + " ".repeat(w - title.length - 1) + "|")
    println("|" + " ".repeat(w) + "|")
    truncated.forEach { println("| $it" + " ".repeat(w - it.length - 1) + "|") }
    println("|" + " ".repeat(w) + "|")
    println(border)
}
// 从 --dart-define 提取环境变量
fun getDartDefines(): Map<String, String> {
    if (project.hasProperty("dart-defines")) {
        return (project.property("dart-defines") as String)
            .split(",")
            .associate { entry ->
                val pair = String(Base64.getDecoder().decode(entry), Charsets.UTF_8).split("=")
                pair[0] to pair[1]
            }
    }
    return emptyMap()
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
}

android {
    namespace = "com.twt.service"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        buildConfig = true
        resValues = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.twt.service"
        multiDexEnabled = true
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        manifestPlaceholders.putAll(mapOf(
            "HUAWEI_APP_ID" to "103402255",
            "XIAOMI_APP_ID" to "2882303761517785783",
            "XIAOMI_APP_KEY" to "5851778525783",
            "MEIZU_APP_ID" to "146410",
            "MEIZU_APP_KEY" to "77b312b3e3b9497bb25298911f7b14d7",
            "VIVO_APP_ID" to "105266463",
            "VIVO_APP_KEY" to "40e5b229553e31f1842b80915781e2e8",
            "OPPO_APP_KEY" to "7cuaXvykA58gkOW4c4oGkG8o0",
            "OPPO_APP_SECRET" to "f7098A23C18d4B504deCB0caaF1d6064",
        ))
    }

    signingConfigs {
        create("config") {
            enableV1Signing = true
            enableV2Signing = true
            try {
                storeFile = file(keystoreProps.getProperty("jksPath"))
                storePassword = keystoreProps.getProperty("storePassword")
                keyAlias = keystoreProps.getProperty("keyAlias")
                keyPassword = keystoreProps.getProperty("storePassword")
            } catch (e: Exception) {
                println("WARNING: No keystore configured. Using debug signing.")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("config")

            var environment = "DEVELOP"
            val env = getDartDefines()
            environment = env["ENVIRONMENT"] ?: "RELEASE"
            println("Packing environment: $environment")

            when (environment) {
                "ONLINE_TEST" -> {
                    manifestPlaceholders["GETUI_APPID"] = "43HGFmIKsnAmjrjDLr60X4"
                    buildConfigField("Boolean", "LOG_OUTPUT", "true")
                    resValue("string", "label", "微北洋$environment")
                    isMinifyEnabled = false
                    isShrinkResources = false
                }
                "DEVELOP" -> {
                    manifestPlaceholders["GETUI_APPID"] = "bj16oBtQ3VAvqPbGtEHB69"
                    applicationIdSuffix = ".develop"
                    buildConfigField("Boolean", "LOG_OUTPUT", "true")
                    resValue("string", "label", "微北洋$environment")
                    isMinifyEnabled = false
                    isShrinkResources = false
                }
                "PREVIEW" -> {
                    manifestPlaceholders["GETUI_APPID"] = "43HGFmIKsnAmjrjDLr60X4"
                    buildConfigField("Boolean", "LOG_OUTPUT", "false")
                    applicationIdSuffix = ".preview"
                    resValue("string", "label", "微北洋Preview")
                    isMinifyEnabled = true
                    proguardFiles(
                        getDefaultProguardFile("proguard-android-optimize.txt"),
                        "proguard-rules.pro"
                    )
                    isShrinkResources = true
                }
                else -> {
                    environment = "RELEASE"
                    manifestPlaceholders["GETUI_APPID"] = "43HGFmIKsnAmjrjDLr60X4"
                    buildConfigField("Boolean", "LOG_OUTPUT", "false")
                    resValue("string", "label", "微北洋")
                    isMinifyEnabled = true
                    proguardFiles(
                        getDefaultProguardFile("proguard-android-optimize.txt"),
                        "proguard-rules.pro"
                    )
                    isShrinkResources = true
                }
            }

            // 自定义输出文件名
            val versionCode = getDartDefines()["VERSIONCODE"] ?: "0"
            applicationVariants.configureEach {
                outputs.configureEach {
                    (this as com.android.build.gradle.internal.api.BaseVariantOutputImpl).apply {
                        outputFileName = environment + "-" +
                            defaultConfig.versionName + "+" + versionCode + "-" +
                            outputFileName
                    }
                }
            }
        }

        debug {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            buildConfigField("Boolean", "LOG_OUTPUT", "true")

            var environment = "DEVELOP"
            if (project.hasProperty("dart-defines")) {
                val env = getDartDefines()
                if (env["ENVIRONMENT"] == "RELEASE") {
                    environment = "RELEASE"
                }
            }
            when (environment) {
                "RELEASE" -> {
                    resValue("string", "label", "微北洋DEBUG_RELEASE")
                    manifestPlaceholders["GETUI_APPID"] = "43HGFmIKsnAmjrjDLr60X4"
                }
                else -> {
                    applicationIdSuffix = ".develop"
                    resValue("string", "label", "微北洋DEBUG_DEVELOP")
                    manifestPlaceholders["GETUI_APPID"] = "bj16oBtQ3VAvqPbGtEHB69"
                }
            }
        }
    }
}

flutter {
    source = "../.."
}

// 读取 Flutter SDK 版本 (FVM 下目录名即版本号，否则取 engine commit 前8位)
val flutterSdkPath = localProperties.getProperty("flutter.sdk") ?: "unknown"
val sdkDirName = file(flutterSdkPath).name
val flutterVersion = if (sdkDirName.matches(Regex("\\d+\\.\\d+\\.\\d+"))) {
    sdkDirName
} else {
    val engineFile = file("$flutterSdkPath/bin/internal/engine.version")
    if (engineFile.exists()) engineFile.readText().trim().take(8) else "unknown"
}

val dartDefineEntries = getDartDefines()
val dartDefineLines = if (dartDefineEntries.isNotEmpty()) {
    listOf("Dart Defines:") + dartDefineEntries.map { "  ${it.key}=${it.value}" }
} else {
    listOf("Dart Defines: (none)")
}

val jvmMaxMemoryMB = Runtime.getRuntime().maxMemory() / 1024 / 1024

printTitledBox("BuildInfo", listOf(
    "App ID: ${android.namespace}",
    "Version: $flutterVersionName (code: $flutterVersionCode)",
    "Build Mode: ${localProperties.getProperty("flutter.buildMode") ?: "unknown"}",
    "Flutter: $flutterVersion",
    "Flutter SDK: $flutterSdkPath",
    "Compile SDK: ${flutter.compileSdkVersion}",
    "Min SDK: ${flutter.minSdkVersion}",
    "Target SDK: ${flutter.targetSdkVersion}",
    "NDK: ${flutter.ndkVersion}",
    "Gradle: ${project.gradle.gradleVersion}",
    "Kotlin: ${KotlinVersion.CURRENT}",
    "Java: ${System.getProperty("java.version")}",
    "Java Home: ${System.getProperty("java.home")}",
    "OS: ${System.getProperty("os.name")} ${System.getProperty("os.version")}",
    "OS Arch: ${System.getProperty("os.arch")}",
    "CPUs: ${Runtime.getRuntime().availableProcessors()}",
    "Max Memory: $jvmMaxMemoryMB MB",
) + dartDefineLines)

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    implementation("com.android.support:multidex:1.0.3")
    implementation(platform("com.squareup.okhttp3:okhttp-bom:4.9.0"))
    implementation("com.squareup.okhttp3:okhttp")
    implementation("com.squareup.okhttp3:logging-interceptor")
    implementation("com.google.code.gson:gson:2.8.6")
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.5.2")
    implementation("androidx.work:work-runtime-ktx:2.7.1")
    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.4.1")
    implementation("com.amap.api:location:6.0.0")
    implementation("com.getui:gtsdk:3.2.8.0")
    implementation("com.getui:gtc:3.1.7.0")
    implementation("com.getui.opt:hwp:3.1.0")
    implementation("com.getui.opt:xmp:3.1.1")
    implementation("com.assist-v3:oppo:3.1.0")
    implementation("com.assist-v3:vivo:3.1.0")
    implementation("com.getui.opt:mzp:3.2.0")
    implementation("com.huawei.hms:push:6.1.0.300")
    implementation("com.umeng.umsdk:common:9.4.7")
    implementation("com.umeng.umsdk:asms:1.5.0")
    implementation("com.umeng.umsdk:apm:1.6.2")
    implementation("com.umeng.umsdk:push:6.5.5")
    implementation("com.umeng.umsdk:abtest:1.0.0")
}
