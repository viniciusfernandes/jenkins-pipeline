def call(Map config = [:]) {
    echo "Loaded javaPipeline.groovy from shared library"
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
                    sh "docker build -t ${config.image ?: 'myapp:latest'} ."
                }
            }
        }
    }
}
