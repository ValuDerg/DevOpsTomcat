pipeline {
    agent any

    environment {
        IMAGE_NAME = 'devops-tomcat-app'
        CONTAINER_NAME = 'tomcat'
        PORT = '8888'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/ValuDerg/DevOpsTomcat'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${IMAGE_NAME}:latest .
                    """
                }
            }
        }

        stage('Redeploy Container') {
            steps {
                script {
                    sh """
                        docker rm -f ${CONTAINER_NAME} 2>/dev/null || true

                        docker run -d \\
                          --name ${CONTAINER_NAME} \\
                          --restart unless-stopped \\
                          -p ${PORT}:8080 \\
                          ${IMAGE_NAME}:latest
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Deployment complete.'
        }
        failure {
            echo 'ERROR: Check logs.'
        }
    }
}
