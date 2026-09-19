try {
    val processEnvironmentClass = Class.forName("java.lang.ProcessEnvironment")
    val theEnvironmentField = processEnvironmentClass.getDeclaredField("theEnvironment")
    theEnvironmentField.isAccessible = true
    @Suppress("UNCHECKED_CAST")
    val map = theEnvironmentField.get(null) as MutableMap<String, String>
    map.remove("ANDROID_PREFS_ROOT")
    map.remove("ANDROID_USER_HOME")

    val theCaseInsensitiveEnvironmentField = processEnvironmentClass.getDeclaredField("theCaseInsensitiveEnvironment")
    theCaseInsensitiveEnvironmentField.isAccessible = true
    @Suppress("UNCHECKED_CAST")
    val ciMap = theCaseInsensitiveEnvironmentField.get(null) as MutableMap<String, String>
    ciMap.remove("ANDROID_PREFS_ROOT")
    ciMap.remove("ANDROID_USER_HOME")
} catch (e: Exception) {
}

allprojects {
    repositories {
        google()
        mavenCentral()
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
