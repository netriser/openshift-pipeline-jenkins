pipeline {
    agent any
    environment {
        OPENSHIFT_API_URL = 'https://api.crc.testing:6443' // URL de votre cluster OpenShift
        OPENSHIFT_TOKEN = credentials('openshift-token')  // ID du Credential Jenkins
        OPENSHIFT_PROJECT = 'mon-projet' // Nom du projet OpenShift
    }
    stages {
        stage('Setup Environment') {
            steps {
                script {
                    // Configurer le fichier KUBECONFIG et se connecter à OpenShift
                    withEnv(["PATH+OC=${tool 'oc3.11'}", "KUBECONFIG=${env.WORKSPACE}/kubeconfig"]) {
                        sh """
                        echo 'Initializing KUBECONFIG and OpenShift CLI...'
                        oc login ${OPENSHIFT_API_URL} --token=${OPENSHIFT_TOKEN} --insecure-skip-tls-verify
                        echo 'Switching to project ${OPENSHIFT_PROJECT}...'
                        oc project ${OPENSHIFT_PROJECT}
                        """
                    }
                }
            }
        }
        stage('Cleanup Workspace') {
            steps {
                cleanWs() // Nettoyer l'espace de travail Jenkins
            }
        }
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/netriser/openshift-pipeline-jenkins.git'
            }
        }
        stage('Lint HTML') {
            steps {
                sh """
                echo 'Linting HTML...'
                if grep -q '<h1>' index.html; then echo 'Lint Passed'; else exit 1; fi
                """
            }
        }
        stage('Build Image') {
            steps {
                script {
                    withEnv(["PATH+OC=${tool 'oc3.11'}", "KUBECONFIG=${env.WORKSPACE}/kubeconfig"]) {
                        sh """
                        echo 'Starting OpenShift build in project ${OPENSHIFT_PROJECT}...'
                        oc project ${OPENSHIFT_PROJECT}
                        oc start-build html-nginx-build --from-dir=. --follow
                        """
                    }
                }
            }
        }
        stage('Deploy to OpenShift') {
            steps {
                script {
                    withEnv(["PATH+OC=${tool 'oc3.11'}", "KUBECONFIG=${env.WORKSPACE}/kubeconfig"]) {
                        sh """
                        echo 'Deploying application in project ${OPENSHIFT_PROJECT}...'
                        oc project ${OPENSHIFT_PROJECT}
                        if oc get dc html-nginx; then
                            echo 'DeploymentConfig exists, rolling out...'
                            oc rollout status dc/html-nginx
                        else
                            echo 'Creating new application...'
                            oc new-app html-nginx-build
                        fi
                        """
                    }
                }
            }
        }
        stage('Expose Route') {
            steps {
                script {
                    withEnv(["PATH+OC=${tool 'oc3.11'}", "KUBECONFIG=${env.WORKSPACE}/kubeconfig"]) {
                        sh """
                        echo 'Exposing service route in project ${OPENSHIFT_PROJECT}...'
                        oc project ${OPENSHIFT_PROJECT}
                        if ! oc get route html-nginx; then
                            oc expose svc/html-nginx
                            echo 'Route exposed successfully.'
                        else
                            echo 'Route already exists.'
                        fi
                        """
                    }
                }
            }
        }
    }
    post {
        always {
            // Nettoyer le fichier KUBECONFIG après exécution
            sh """
            echo 'Cleaning up KUBECONFIG...'
            rm -f ${env.WORKSPACE}/kubeconfig
            """
        }
    }
}
