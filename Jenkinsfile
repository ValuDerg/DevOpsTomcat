pipeline {
    agent any

    environment {
        // The host directory mounted into the Tomcat container.
        // Jenkins writes here; Tomcat reads from here automatically.
        DEPLOY_DIR = '/home/valu/Documents/devops-webpage'

        // Your GitHub repository URL.
        REPO_URL = 'https://github.com/ValuDerg/DevOpsTomcat.git'

        // Branch to deploy.
        BRANCH = 'main'
    }

    stages {

        stage('Pull latest code') {
            steps {
                script {
                    // If the deploy directory already contains a git repo, pull.
                    // Otherwise, clone fresh.
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

        stage('Redeploy containers') {
            steps {
                script {
                    sh """
                        # Stop and remove both containers if they are running.
                        docker rm -f jenkins tomcat || true

                        # Re-create both containers using the compose file.
                        # The compose file lives next to the Jenkinsfile in the repo,
                        # so Jenkins already checked it out via SCM.
                        docker compose -f ${WORKSPACE}/docker-compose.yml up -d
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
