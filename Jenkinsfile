pipeline {
    agent any
    environment {
        DOCKER_CRED = credentials('dockerhub-abhi144k')
        DOCKER_USER = 'abhi144k'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Infrastructure') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage('Secrets (Ansible)') {
            environment {
                // Force Ansible/K8s to use our fixed config
                K8S_AUTH_KUBECONFIG = '/var/jenkins_home/.kube/config-jenkins'
            }
            steps {
                dir('ansible') {
                    // We update the secrets.yaml command to use the env var automatically
                    sh 'ansible-playbook -i inventory.ini secrets.yaml'
                }
            }
        }
        stage('Build & Push') {
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
        stage('Deploy') {
            steps {
                sh "helm upgrade --install mern-app ./k8s-helm --namespace mern-namespace --set backend.image=$DOCKER_USER/mern-backend --set frontend.image=$DOCKER_USER/mern-frontend"
            }
        }
    }
}