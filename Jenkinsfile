versions = ['3.7', '3.8', '3.9', '3.10', '3.11', '3.12', '3.13', '3.14']

pipeline {

    agent { label 'docker-agent' }

    stages {
        stage ( "Building") {
            steps {
                script {
                    versions.each { version ->
                        docker.withRegistry('', 'docker-hub-credentials') {
                            stage("version ${version}") {
                                sh "make build v=${version}"
                                sh "make build-dev v=${version}"
                                sh "make push v=${version}"
                                sh "make push-dev v=${version}"
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                sh 'make remove'
            }
        }
        cleanup {
            cleanWs()
        }
    }
}
