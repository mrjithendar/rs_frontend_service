pipeline {

    agent any

    environment {
        tfDir = "terraform"
        region = "us-east-1"
        AWSCreds = credentials('awsCreds')
        AWS_ACCESS_KEY_ID = "${AWSCreds_USR}"
        AWS_SECRET_ACCESS_KEY = "${AWSCreds_PSW}"
        AWS_DEFAULT_REGION = "us-east-1"
        AWS_ACCOUNT_ID = "826334059644"
        vault = credentials('vaultToken')
        tfvars = "vars/${params.Options}.tfvars"
        eks_cluster_name = "roboshop-eks-cluster-demo"
        service = "frontend_demo"
    }

    stages {


        stage ('Docker Login') {
            steps {
                sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
            }
        }

        stage ('Build Docker Images') {
            steps {
                sh "docker build -t ${service} ."
                sh "docker tag ${service}:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${service}:latest"
                sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${service}:latest"
            }
        }

        stage ('EKS Acthenticate') {
            steps {
                sh "aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name ${eks_cluster_name}"
            }
        }

        stage ('Deploy App') {
            steps {
                sh "curl -o -L https://raw.githubusercontent.com/mrjithendar/tools/master/namespace.sh"
                sh "sh namespace.sh"
                sh "kubectl apply -f k8s/deployment.yml"
                sh "kubectl apply -f k8s/service.yml"
            }
        }
    }
}
