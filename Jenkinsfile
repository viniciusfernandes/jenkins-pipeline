def call(Map config = [:]) {
    pipeline {
        agent any
        environment {
            JAVA_HOME = "/usr/lib/jvm/java-21-openjdk"
            DOCKER_IMAGE = "${config.image ?: 'default-app:latest'}"
        }

        stages {
            stage('Checkout') {
                steps {
                    git branch: "${config.branch ?: 'main'}", url: config.repo
                }
            }

            stage('Build') {
                steps {
                    sh './mvnw clean compile -B'
                }
            }

            stage('Test') {
                steps {
                    sh './mvnw test -B'
                }
                post {
                    always {
                        junit '**/target/surefire-reports/*.xml'
                    }
                }
            }

            stage('Package') {
                steps {
                    sh './mvnw package -DskipTests -B'
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }

            stage('Docker Build') {
                steps {
                    sh "docker build -t $DOCKER_IMAGE ."
                }
            }
        }

        post {
            success { echo "✅ Build completed successfully" }
            failure { echo "❌ Build failed" }
        }
    }
}
