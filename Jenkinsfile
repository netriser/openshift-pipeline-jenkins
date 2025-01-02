pipeline {
    agent any
    triggers {
        githubPush() // Déclenchement automatique sur les commits GitHub
    }
    environment {
        OPENSHIFT_API_URL = 'https://api.crc.testing:6443' // URL de votre cluster OpenShift
        OPENSHIFT_TOKEN = credentials('openshift-token')  // ID de vos Credentials Jenkins
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/votre-depot/openshift-pipeline.git'
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
                                echo 'Deploying new application...'
                                openshift.newApp('html-nginx-build')
                            } else {
                                echo 'Updating existing deployment...'
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
                            } else {
                                echo 'Route already exists.'
                            }
                        }
                    }
                }
            }
        }
    }
}
