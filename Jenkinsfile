pipeline {
    agent any
    environment {
        DOCKER_CRED = credentials('dockerhub-abhi144k')
        DOCKER_USER = 'abhi144k'
    }
    stages {
        stage('Checkout') {
            steps { git branch: 'main', url: 'https://github.com/AKS144/mern-devops-14122025.git' }
        }
        stage('Infrastructure') {
            steps { dir('terraform') { sh 'terraform init && terraform apply -auto-approve' } }
        }
        stage('Secrets') {
            steps { dir('ansible') { sh 'ansible-playbook -i inventory.ini secrets.yaml' } }
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