pipeline {
    agent any

    environment {
        DEPLOY_DIR = '/home/valu/Documents/devops-webpage/DevOpsTomcat'
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
                        # Only remove and recreate Tomcat.
                        # Never touch the Jenkins container — it is running this pipeline.
                        docker rm -f tomcat || true

                        # Start Tomcat with plain docker run — no compose needed at runtime.
                        docker run -d \
                            --name tomcat \
                            --restart unless-stopped \
                            -p 8888:8080 \
                            -v /home/valu/Documents/devops-webpage/DevOpsTomcat:/usr/local/tomcat/webapps/ROOT \
                            tomcat:11
                    """
                }
            }
        }

    }

    post {
        success {
            echo 'Deployment complete. Tomcat is serving the updated content.'
        }
        failure {
            echo 'Pipeline failed. Check the stage logs above for details.'
        }
    }
}
