def call(Map config = [:]) {
    pipeline {
        agent any

        environment {
            GRADLE_OPTS = "-Dorg.gradle.daemon=false"
        }

        stages {
            stage('Checkout') {
                steps {
                    echo "🔄 Checking out branch: ${config.branch ?: 'main'}"
                    git branch: config.branch ?: 'main', url: config.repo
                }
            }

            stage('Build') {
                steps {
                    echo "🏗️ Building project with Gradle..."
                    sh './gradlew clean build -x test'
                }
            }

            stage('Test') {
                steps {
                    echo "🧪 Running tests..."
                    sh './gradlew test'
                }
                post {
                    always {
                        junit '**/build/test-results/test/*.xml'
                    }
                }
            }

            stage('Package') {
                steps {
                    echo "📦 Creating application JAR..."
                    sh './gradlew jar'
                    archiveArtifacts artifacts: 'build/libs/*.jar', fingerprint: true
                }
            }

            stage('Docker Build') {
                steps {
                    echo "🐳 Building Docker image..."
                    sh "docker build -t ${config.image ?: 'myapp:latest'} ."
                }
            }
        }

        post {
            success {
                echo "✅ Pipeline completed successfully for ${config.repo}"
            }
            failure {
                echo "❌ Pipeline failed for ${config.repo}"
            }
        }
    }
}
