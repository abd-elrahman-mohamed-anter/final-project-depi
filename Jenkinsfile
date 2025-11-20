pipeline {
    agent any

    environment {
        // GitHub Settings
        GITHUB_USER = "rabiaadel"
        GITHUB_REPO = "rabiaadel/devops-javafullstack-final-project"
        GITHUB_CHECKOUT_CREDS = 'github-creds'
        
        // SonarQube Token
        SONAR_FINAL_TOKEN = credentials('SONAR_FINAL_TOKEN')

        // Docker Hub Settings
        DOCKERHUB_USER = "rabiaadel"
        DOCKERHUB_REPO = "${DOCKERHUB_USER}/final-project"
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
                sh '''
                    mvn -version
                    mvn -B clean package -DskipTests
                '''
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
                            -Dsonar.login=$SONAR_FINAL_TOKEN
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${DOCKERHUB_REPO}:${BUILD_NUMBER} .
                    docker tag ${DOCKERHUB_REPO}:${BUILD_NUMBER} ${DOCKERHUB_REPO}:latest
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKERHUB_REPO}:${BUILD_NUMBER}
                        docker push ${DOCKERHUB_REPO}:latest
                    '''
                }
            }
        }
    } // ← FIXED: closing stages

    post {
        success {
            echo "Pipeline finished successfully! Image pushed: ${DOCKERHUB_REPO}:${BUILD_NUMBER}"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
