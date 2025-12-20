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

        // stage('Infrastructure (Terraform)') {
        //     steps {
        //         dir('terraform') {
        //             // Clean previous state to prevent locking errors
        //             sh 'rm -rf .terraform .terraform.lock.hcl'
        //             sh 'terraform init'
        //             sh 'terraform apply -auto-approve'
        //         }
        //     }
        // }

        stage('Infrastructure (Terraform)') {
            steps {
                withCredentials([file(credentialsId: 'k8s-kubeconfig', variable: 'KUBECONFIG')]) {
                    dir('terraform') {
                        sh 'rm -rf .terraform .terraform.lock.hcl'
                        sh 'terraform init'
                        
                        script {
                            // Try to import the namespace. If it fails (because it's not there), 
                            // that's fine, the next 'apply' command will just create it.
                            sh "terraform import -var 'kube_config=${KUBECONFIG}' kubernetes_namespace_v1.mern_ns mern-namespace || echo 'Namespace not found or already managed'"
                        }
                        
                        sh "terraform apply -auto-approve -var 'kube_config=${KUBECONFIG}'"
                    }
                }
            }
        }

        stage('Secrets (Ansible)') {
            steps {
                withCredentials([file(credentialsId: 'k8s-kubeconfig', variable: 'KUBECONFIG')]) {
                    dir('ansible') {
                        // Explicitly set the K8S_AUTH_KUBECONFIG environment variable for Ansible
                        withEnv(["K8S_AUTH_KUBECONFIG=${KUBECONFIG}"]) {
                            sh 'ansible-playbook -i inventory.ini secrets.yaml'
                        }
                    }
                }
            }
        }

        // stage('Build & Push Docker') {
        //     steps {
        //         script {
        //             sh 'echo $DOCKER_CRED_PSW | docker login -u $DOCKER_CRED_USR --password-stdin'
                    
        //             sh "docker build -t $DOCKER_USER/mern-backend:latest ./backend"
        //             sh "docker push $DOCKER_USER/mern-backend:latest"
                    
        //             sh "docker build -t $DOCKER_USER/mern-frontend:latest ./frontend"
        //             sh "docker push $DOCKER_USER/mern-frontend:latest"
        //         }
        //     }
        // }

        stage('Build & Push Docker') {
            steps {
                script {
                    sh 'echo $DOCKER_CRED_PSW | docker login -u $DOCKER_CRED_USR --password-stdin'
                    
                    sh "docker build -t $DOCKER_USER/mern-backend:latest ./backend"
                    sh "docker push $DOCKER_USER/mern-backend:latest"
                    
                    // DEBUG: Print the Frontend Dockerfile to log to verify it has 'npx'
                    sh "cat frontend/Dockerfile"

                    // Force no cache to pick up the new file
                    sh "docker build --no-cache -t $DOCKER_USER/mern-frontend:latest ./frontend"
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