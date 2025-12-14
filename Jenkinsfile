pipeline {
    agent any
    
    environment {
        DOCKER_CRED = credentials('dockerhub-abhi144k')
        DOCKER_USER = 'abhi144k'
        // Point to the fixed file we generate
        KUBECONFIG = "${WORKSPACE}/k8s-config-fixed"
        K8S_AUTH_KUBECONFIG = "${WORKSPACE}/k8s-config-fixed"
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
                    echo "Reading and Fixing Kubernetes Config..."
                    
                    // 1. Read the mounted config file into a variable
                    String configContent = readFile file: '/var/jenkins_home/.kube/config'
                    
                    // 2. Fix IPs (localhost -> minikube)
                    configContent = configContent.replace('127.0.0.1', 'minikube')
                    configContent = configContent.replace('localhost', 'minikube')
                    configContent = configContent.replace('server: https://minikube:8443', 'server: https://minikube:8443') 
                    // (The line above ensures we don't double-replace, but keeps it safe)
                    
                    // 3. Fix Windows Paths (Regex to swap C:\Users\Name with /var/jenkins_home)
                    // Matches "C:\Users\ANYTHING"
                    configContent = configContent.replaceAll(/C:\\Users\\[^\\]+/, '/var/jenkins_home')
                    
                    // 4. Fix Backslashes to Forward Slashes
                    configContent = configContent.replace('\\', '/')
                    
                    // 5. Save to Workspace
                    writeFile file: 'k8s-config-fixed', text: configContent
                    
                    // 6. Verify it looks correct (print first 10 lines)
                    sh 'head -n 10 k8s-config-fixed'
                }
            }
        }

        stage('Infrastructure (Terraform)') {
            steps {
                dir('terraform') {
                    // Clean previous terraform state to force reload
                    sh 'rm -rf .terraform .terraform.lock.hcl'
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Secrets (Ansible)') {
            steps {
                dir('ansible') {
                    // Ansible uses the env var K8S_AUTH_KUBECONFIG automatically
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
                   --kubeconfig ${WORKSPACE}/k8s-config-fixed
                """
            }
        }
    }
}