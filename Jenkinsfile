pipeline {
        agent any
        environment {
                    GRADLE_OPTS = "-Dorg.gradle.daemon=false"
                }

		parameters {
        	string(name: 'VERSION', description: 'Version tag for the Docker image (e.g., 1.0.0)', defaultValue: '')
    	}
		
        stages {
            stage('Checkout') {
                steps {
                    git branch: 'master', url: 'https://github.com/viniciusfernandes/authentication-api.git'
                }
            }
            stage('Build') {
                steps {
                    echo "Building version: ${params.VERSION}"
                    sh "./gradlew build -x test"
                }
            }
            stage('Test') {
                steps {
                    sh './gradlew test'
                }

            }
            stage('Package') {
                steps {
                    sh './gradlew jar -x test'
                    archiveArtifacts artifacts: 'build/libs/*.jar', fingerprint: true
                }
            }
			stage('Docker Build & Tag') {
                steps {
                    script {
                        if (!params.VERSION?.trim()) {
                            error "VERSION parameter is mandatory! Please set it when triggering the build."
                        }

                        def imageTag = "my-app:${params.VERSION}"
                        echo "Building Docker image: ${imageTag}"
                        sh "docker build -t ${imageTag} ."
                    }
                }
            }
        }
}