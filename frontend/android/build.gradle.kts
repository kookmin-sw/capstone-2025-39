import java.util.Properties

// 함수 정의 먼저
fun loadEnvProperty(key: String): String {
    val props = Properties()
    val envFile = File(rootDir, ".env")
    if (!envFile.exists()) return ""
    props.load(envFile.inputStream())
    return props.getProperty(key) ?: ""
}

// 그 다음에 extra 등록
extra["GOOGLE_MAPS_API_KEY"] = loadEnvProperty("GOOGLE_MAPS_API_KEY")

// 나머지 설정
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}