pipeline {
    agent {
        docker {
            image 'maven:3.9.6-eclipse-temurin-17'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        GITHUB_USER = "rabiaadel"
        GITHUB_REPO = "rabiaadel/devops-javafullstack-final-project"
        IMAGE_NAME = "ghcr.io/${GITHUB_REPO}"
        IMAGE_TAG = "v${env.BUILD_NUMBER}"

        // Jenkins credentials
        GITHUB_CHECKOUT_CREDS = 'github-creds'
        GITHUB_FINAL_TOKEN = credentials('GITHUB_FINAL_TOKEN')
        SONAR_FINAL_TOKEN = credentials('SONAR_FINAL_TOKEN')
        DOCKERHUB_USER = "rabiaadel"
        DOCKERHUB_TOKEN = credentials('DOCKERHUB_FINAL_TOKEN')
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
                sh """
                    mvn -version
                    mvn -B clean package -DskipTests
                """
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        mvn sonar:sonar \
                        -DskipTests \
                        -Dsonar.projectKey=jenkins-ci \
                        -Dsonar.host.url=http://host.docker.internal:9000 \
                        -Dsonar.login=${SONAR_FINAL_TOKEN}
                    """
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh """
                    echo "Logging into Docker Hub..."
                    echo ${DOCKERHUB_TOKEN} | docker login -u ${DOCKERHUB_USER} --password-stdin

                    echo "Building Docker image..."
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .

                    echo "Pushing Docker image..."
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}

                    echo "Image pushed successfully!"
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
