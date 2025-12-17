pipeline {
    agent any
    
    environment {
        // Must match the ID you created in Jenkins for DockerHub
        DOCKER_CRED = credentials('dockerhub-abhi144k')
        DOCKER_USER = 'abhi144k'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Infrastructure (Terraform)') {
            steps {
                dir('terraform') {
                    // Clean previous state to prevent locking errors
                    sh 'rm -rf .terraform .terraform.lock.hcl'
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Secrets (Ansible)') {
            steps {
                dir('ansible') {
                    // No special flags needed anymore
                    sh 'ansible-playbook -i inventory.ini secrets.yaml'
                }
            }
        }

        stage('Build & Push Docker') {
            steps {
                script {
                    sh 'echo $DOCKER_CRED_PSW | docker login -u $DOCKER_CRED_USR --password-stdin'
                    
                    sh "docker build -t $DOCKER_USER/mern-backend:latest ./backend"
                    sh "docker push $DOCKER_USER/mern-backend:latest"
                    
                    sh "docker build -t $DOCKER_USER/mern-frontend:latest ./frontend"
                    sh "docker push $DOCKER_USER/mern-frontend:latest"
                }
            }
        }

        stage('Deploy (Helm)') {
            steps {
                // Helm finds the config at ~/.kube/config automatically
                sh """
                   helm upgrade --install mern-app ./k8s-helm \
                   --namespace mern-namespace \
                   --set backend.image=$DOCKER_USER/mern-backend \
                   --set frontend.image=$DOCKER_USER/mern-frontend
                """
            }
        }
    }
}