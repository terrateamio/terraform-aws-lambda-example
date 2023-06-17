pipeline{
    agent any
    stages {
        stage('Git checkout') {
            steps {
                git credentialsId: 'github', url: 'https://github.com/terrateamio/terraform-aws-lambda-example.git'
            }

        }
    }
}
