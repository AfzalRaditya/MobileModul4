import com.android.build.gradle.LibraryExtension
import org.gradle.kotlin.dsl.configure

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")
    }
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

// Ensure library plugins coming from older plugins without 'namespace' still build
subprojects {
    plugins.withId("com.android.library") {
        configure<LibraryExtension> {
            try {
                if (this.namespace.isNullOrBlank()) {
                    this.namespace = "com.kelompokmobile"
                }
            } catch (e: Exception) {
                // ignore if extension not available yet
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
