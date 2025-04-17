allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
// rootProject.layout.buildDirectory.value(newBuildDir)

<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> e9fc20e (프로젝트 구조 수정)
// subprojects {
//     val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//     project.layout.buildDirectory.value(newSubprojectBuildDir)
// }
// subprojects {
//     project.evaluationDependsOn(":app")
// }
<<<<<<< HEAD

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
<<<<<<< HEAD
}
=======
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
=======
>>>>>>> e9fc20e (프로젝트 구조 수정)

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
<<<<<<< HEAD

fun loadEnvProperty(key: String): String {
    val envFile = rootProject.file(".env")
    if (!envFile.exists()) return ""
    val props = Properties()
    props.load(envFile.inputStream())
    return props.getProperty(key) ?: ""
}

extra["GOOGLE_MAPS_API_KEY"] = loadEnvProperty("GOOGLE_MAPS_API_KEY")
>>>>>>> 55ebd0d (지도 기능 구현)
=======
>>>>>>> e9fc20e (프로젝트 구조 수정)
=======
}
>>>>>>> 1213d29 (로그인 ui수정)
