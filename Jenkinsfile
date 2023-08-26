pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('access_key')
        AWS_SECRET_ACCESS_KEY = credentials('secret_key')
    }

    stages{
        stage('vcs') {
            steps {
                git url: 'https://github.com/divyakothuru311/test.git',
                       branch: 'main'
            }
        }
        stage('create vm via terraform') {
            steps {
            //     sh 'terraform init'
            //     sh 'terraform validate'
            //     sh 'terraform apply -var-file="dev.tfvars" -auto-approve'
                   sh 'terraform destroy -var-file="dev.tfvars" -auto-approve'
             }
        }
    }
}