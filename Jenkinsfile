pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
		checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Linda-Annang/project-2.git']]])
               
            }
        }
        stage('Terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform Action') {
            steps {
		echo 'Terraform action is --> ${action}'
                sh 'terraform ${action} --auto-approve'
            }
        }
        
    }
}
