pipeline {
    agent any

    environment {
        DEPLOY_DIR = '/home/valu/Documents/devops-webpage/DevOpsTomcat'
        TOMCAT_DIR = '/usr/local/tomcat/webapps/ROOT'
        REPO_URL   = 'https://github.com/ValuDerg/DevOpsTomcat'
        BRANCH     = 'main'
    }

    stages {

        stage('Pull latest code') {
            steps {
                script {
                    sh """
                        if [ -d "${DEPLOY_DIR}/.git" ]; then
                            git -C ${DEPLOY_DIR} fetch origin ${BRANCH}
                            git -C ${DEPLOY_DIR} reset --hard origin/${BRANCH}
                        else
                            git clone --branch ${BRANCH} ${REPO_URL} ${DEPLOY_DIR}
                        fi
                    """
                }
            }
        }

        stage('Redeploy Tomcat') {
            steps {
                script {
                    sh """
                        # Stop Tomcat
                        docker kill tomcat
                    
                        # Remove Tomcat
                        docker rm -f tomcat || true

                        # Start Tomcat
                        docker run -d \
                            --name tomcat \
                            --restart unless-stopped \
                            -p 8888:8080 \
                            -v ${DEPLOY_DIR}:${TOMCAT_DIR} \
                            tomcat:11
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
            echo 'ERROR: Check the stage logs above for details.'
        }
    }
}
