import java.util.Properties

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

fun loadEnvProperty(key: String): String {
    val envFile = rootProject.file(".env")
    if (!envFile.exists()) return ""
    val props = Properties()
    props.load(envFile.inputStream())
    return props.getProperty(key) ?: ""
}

extra["GOOGLE_MAPS_API_KEY"] = loadEnvProperty("GOOGLE_MAPS_API_KEY")