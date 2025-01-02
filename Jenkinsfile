pipeline {
    agent any
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
                    // Utilisation de la configuration OpenShift Sync Plugin
                    openshift.withCluster() {
                        openshift.withProject() {
                            // Démarrer un build OpenShift
                            def build = openshift.selector('bc', 'html-nginx-build').startBuild('--from-dir=. --follow')
                            build.logs('-f')
                        }
                    }
                }
            }
        }
        stage('Expose Route') {
            steps {
                script {
                    // Vérifier et exposer la route
                    openshift.withCluster() {
                        openshift.withProject() {
                            def svc = openshift.selector('svc', 'html-nginx-build')
                            if (!svc.exists()) {
                                echo "Exposing service..."
                                svc.expose()
                            } else {
                                echo "Service already exposed."
                            }
                        }
                    }
                }
            }
        }
    }
}
