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

        GITHUB_CHECKOUT_CREDS = 'github-creds'
        GITHUB_FINAL_TOKEN = credentials('GITHUB_FINAL_TOKEN')
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
                        -Dsonar.login=${SONAR_FINAL_TOKEN}
                    """
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh """
                    echo ${GITHUB_FINAL_TOKEN} | docker login ghcr.io -u ${GITHUB_USER} --password-stdin
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline finished successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
