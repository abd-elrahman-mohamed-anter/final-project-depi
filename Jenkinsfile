pipeline {
    agent any
    tools {
        maven 'maven38'     // <--- Matches your Jenkins Maven installation
        jdk 'jdk17'         // <--- Matches your Jenkins JDK installation
    }

    environment {
        GITHUB_USER = "rabiaadel"
        GITHUB_REPO = "rabiaadel/devops-javafullstack-final-project"
        IMAGE_NAME = "ghcr.io/${GITHUB_REPO}"
        IMAGE_TAG = "v${env.BUILD_NUMBER}"

        // Jenkins credentials
        GITHUB_CHECKOUT_CREDS = 'github-creds'        // username + password for checkout
        GITHUB_FINAL_TOKEN = credentials('GITHUB_FINAL_TOKEN')  // token for GHCR push
        SONAR_FINAL_TOKEN = credentials('SONAR_FINAL_TOKEN')
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: "https://github.com/${GITHUB_REPO}.git",
                    credentialsId: "${GITHUB_CHECKOUT_CREDS}"
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn -B clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('MySonarServer') {
                    sh """
                        mvn sonar:sonar \
                        -DskipTests \
                        -Dsonar.projectKey=devops-javafullstack-final-project \
                        -Dsonar.login=${SONAR_FINAL_TOKEN}
                    """
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh """
                    echo "Logging into GHCR..."
                    echo ${GITHUB_FINAL_TOKEN} | docker login ghcr.io -u ${GITHUB_USER} --password-stdin

                    echo "Building Docker image..."
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

                    echo "Pushing Docker image..."
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline finished successfully! Image pushed: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
