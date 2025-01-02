pipeline {
    agent any
    environment {
        OPENSHIFT_API_URL = 'https://api.crc.testing:6443' // URL de votre cluster
        OPENSHIFT_TOKEN = credentials('openshift-token') // ID du Credential Jenkins
    }
    stages {
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
                    openshift.withCluster() {
                        openshift.withProject() {
                            def build = openshift.selector('bc', 'html-nginx-build').startBuild('--from-dir=. --follow')
                            build.logs('-f')
                        }
                    }
                }
            }
        }
        stage('Deploy to OpenShift') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            def dc = openshift.selector('dc', 'html-nginx')
                            if (!dc.exists()) {
                                openshift.newApp('html-nginx-build')
                            } else {
                                dc.rollout().status()
                            }
                        }
                    }
                }
            }
        }
        stage('Expose Route') {
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withProject() {
                            def svc = openshift.selector('svc', 'html-nginx-build')
                            if (!svc.exists()) {
                                svc.expose()
                                echo 'Route exposed successfully.'
                            }
                        }
                    }
                }
            }
        }
    }
}
