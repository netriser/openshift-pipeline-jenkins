pipeline {
    agent any
    environment {
        OPENSHIFT_API_URL = 'https://api.crc.testing:6443' // URL de votre cluster
        OPENSHIFT_TOKEN = credentials('openshift-token') // ID du Credential Jenkins
    }
    triggers {
        githubPush() // Déclenchement sur commit GitHub
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/netriser/openshift-pipeline-jenkins.git'
            }
        }
        stage('Lint HTML') {
            steps {
                script {
                    // Ajouter un simple validateur HTML
                    sh """
                    echo 'Linting HTML...'
                    if grep -q '<h1>' index.html; then echo 'Lint Passed'; else exit 1; fi
                    """
                }
            }
        }
        stage('Build and Deploy') {
            steps {
                script {
                    withEnv(["PATH+OC=${tool 'oc3.11'}"]) {
                        sh """
                        oc login ${OPENSHIFT_API_URL} --token=${OPENSHIFT_TOKEN} --insecure-skip-tls-verify
                        oc start-build html-nginx-build --from-dir=. --follow
                        """
                    }
                }
            }
        }
        stage('Expose Route') {
            steps {
                script {
                    withEnv(["PATH+OC=${tool 'oc3.11'}"]) {
                        sh """
                        oc expose svc/html-nginx-build
                        echo 'Route Exposed!'
                        """
                    }
                }
            }
        }
    }
}
