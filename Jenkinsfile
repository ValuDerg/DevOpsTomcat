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
                            cd "${DEPLOY_DIR}"
                            git fetch origin
                            git reset --hard origin/${BRANCH}
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
                        docker rm -f tomcat 2>/dev/null || true
                        
                        docker run -d \\
                        --name tomcat \\
                        --restart unless-stopped \\
                        -p 8888:8080 \\
                        -v ${DEPLOY_DIR}:${TOMCAT_DIR} \\
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
