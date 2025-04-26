import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory
import java.io.File

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0")
        classpath("com.google.gms:google-services:4.4.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }

    tasks.withType<JavaCompile>().configureEach {
        options.encoding = "UTF-8"
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions.jvmTarget = "17"
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    tasks.withType<JavaCompile>().configureEach {
        options.encoding = "UTF-8"
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions.jvmTarget = "17"
    }
}

// Explicitly set task dependencies for shaders
gradle.taskGraph.whenReady {
    val compileReleaseShaders = tasks.findByPath(":app:compileReleaseShaders")
    val packageReleaseAssets = tasks.findByPath(":cloud_firestore:packageReleaseAssets")

    if (compileReleaseShaders != null && packageReleaseAssets != null) {
        // Force task dependency
        packageReleaseAssets.dependsOn(compileReleaseShaders)

        // 🔵 Ensure the shader output directory exists
        packageReleaseAssets.doFirst {
            val shaderOutDir = file("${rootProject.buildDir}/intermediates/shader_assets/release/compileReleaseShaders/out")
            if (!shaderOutDir.exists()) {
                println("⚠️ Shader output missing. Creating dummy shader output folder: $shaderOutDir")
                shaderOutDir.mkdirs()
            }
        }
    }
}

// Global build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
