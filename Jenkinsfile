pipeline {
    agent any
    
    environment {
        DOCKER_CRED = credentials('dockerhub-abhi144k')
        DOCKER_USER = 'abhi144k'
        // Point everyone to the fixed config
        KUBECONFIG = "/var/jenkins_home/workspace/k8s-config-fixed"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Fix Kubernetes Config') {
            steps {
                script {
                    echo "Generating fixed Kubernetes config..."
                    
                    // 1. Copy the config to workspace
                    sh 'cp /var/jenkins_home/.kube/config /var/jenkins_home/workspace/k8s-config-fixed'
                    
                    // 2. Fix IP Addresses (Point to Minikube Docker DNS)
                    sh 'sed -i "s|127.0.0.1|minikube|g" /var/jenkins_home/workspace/k8s-config-fixed'
                    sh 'sed -i "s|localhost|minikube|g" /var/jenkins_home/workspace/k8s-config-fixed'
                    sh 'sed -i "s|server:.*|server: https://minikube:8443|g" /var/jenkins_home/workspace/k8s-config-fixed'

                    // 3. Fix Windows User Paths (C:\Users\...)
                    // Use single quotes for the sh command to protect backslashes
                    sh "sed -i 's|C:\\\\Users\\\\[^/]*|/var/jenkins_home|g' /var/jenkins_home/workspace/k8s-config-fixed"
                    
                    // 4. Fix Backslashes (THE FIX)
                    // We use 'tr' instead of 'sed' here because it is safer for backslashes
                    sh 'cat /var/jenkins_home/workspace/k8s-config-fixed | tr "\\\\" "/" > /var/jenkins_home/workspace/k8s-config-temp'
                    sh 'mv /var/jenkins_home/workspace/k8s-config-temp /var/jenkins_home/workspace/k8s-config-fixed'

                    // 5. Verify content (Check if file looks right in logs)
                    sh 'cat /var/jenkins_home/workspace/k8s-config-fixed'
                }
            }
        }

        stage('Infrastructure (Terraform)') {
            steps {
                dir('terraform') {
                    // Clean up Terraform lock files to prevent errors
                    sh 'rm -rf .terraform .terraform.lock.hcl'
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Secrets (Ansible)') {
            environment {
                K8S_AUTH_KUBECONFIG = "/var/jenkins_home/workspace/k8s-config-fixed"
            }
            steps {
                dir('ansible') {
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
                sh """
                   helm upgrade --install mern-app ./k8s-helm \
                   --namespace mern-namespace \
                   --set backend.image=$DOCKER_USER/mern-backend \
                   --set frontend.image=$DOCKER_USER/mern-frontend \
                   --kubeconfig /var/jenkins_home/workspace/k8s-config-fixed
                """
            }
        }
    }
}