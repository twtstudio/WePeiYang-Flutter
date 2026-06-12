// 基于 Flutter 3.44.2 模板，添加项目专属的 maven 仓库
// Huawei AGConnect 插件要求 buildscript 中存在 AGP classpath
buildscript {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        google()
        mavenCentral()
        maven { url = uri("https://developer.huawei.com/repo/") }
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("com.huawei.agconnect:agcp:1.9.1.301")
    }
}

allprojects {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        google()
        mavenCentral()
        // 个推
        maven { url = uri("https://mvn.getui.com/nexus/content/repositories/releases/") }
        // 友盟
        maven { url = uri("https://repo1.maven.org/maven2/") }
        // OPPO
        maven {
            url = uri("https://maven.columbus.heytapmobi.com/repository/releases/")
            credentials {
                username = "nexus"
                password = "c0b08da17e3ec36c3870fed674a0bcb36abc2e23"
            }
        }
        // 华为
        maven { url = uri("https://developer.huawei.com/repo/") }
        // 荣耀
        maven { url = uri("https://developer.hihonor.com/repo/") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
