import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = System.getenv("LOCALAPPDATA")
    ?.takeIf { it.isNotBlank() }
    ?.let { File(it, "HandloomBazarCustomerApp/build") }
    ?: File(rootDir, "../../build")

newBuildDir.mkdirs()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    project.layout.buildDirectory.set(File(newBuildDir, project.name))
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(newBuildDir)
}
