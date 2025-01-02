pipeline {
    agent any
    environment {
        OPENSHIFT_API_URL = 'https://api.crc.testing:6443'
        OPENSHIFT_TOKEN = credentials('openshift-token') // ID du Credential Jenkins
        OPENSHIFT_PROJECT = 'mon-projet'
    }
    stages {
        stage('Setup Environment') {
            steps {
                script {
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
                        # Vérify if route exists
                        if oc get route html-nginx-build > /dev/null 2>&1; then
                            echo 'Route already exists.'
                        else
                            # Vérify if service existe
                            if oc get svc html-nginx-build > /dev/null 2>&1; then
                                echo 'Service exists, creating route...'
                            else
                                echo 'Service does not exist, creating service...'
                                # Crée le service basé sur le DeploymentConfig
                                oc expose dc/html-nginx-build
                            fi
                            # Crée la route
                            oc expose svc/html-nginx-build
                            echo 'Route exposed successfully.'
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