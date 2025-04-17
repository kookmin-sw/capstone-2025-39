allprojects {
    repositories {
        google()
        mavenCentral()
    }
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
