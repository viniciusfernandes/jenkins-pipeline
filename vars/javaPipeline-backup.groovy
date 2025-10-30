def call(Map config = [:]) {
    pipeline {
        agent any
        stages {
            stage('Checkout') {
                steps {
                    git branch: config.branch ?: 'main', url: config.repo
                }
            }
            stage('Build') {
                steps {
                    sh './gradlew build -x test'
                }
            }
            stage('Test') {
                steps {
                    sh './gradlew test'
                }
                post {
                    always {
                        junit '**/target/surefire-reports/*.xml'
                    }
                }
            }
            stage('Package') {
                steps {
                    sh './gradlew package -DskipTests -B'
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
            stage('Docker Build') {
                steps {
                    sh "docker build -t ${config.image ?: 'myapp:latest'} ."
                }
            }
        }
    }
}
