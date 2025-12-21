pipeline {
    agent any
    environment {
        DOCKER_CRED = credentials('dockerhub-abhi144k')
        DOCKER_USER = 'abhi144k'
    }
    stages {
        stage('Checkout') { steps { checkout scm } }
        stage('Infrastructure') {
            steps {
                withCredentials([file(credentialsId: 'k8s-kubeconfig', variable: 'KUBECONFIG')]) {
                    dir('terraform') {
                        sh 'rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup'
                        sh 'terraform init'
                        script {
                             sh "terraform import -var 'kube_config=${KUBECONFIG}' kubernetes_namespace_v1.mern_ns mern-namespace || echo 'Namespace managed'"
                        }
                        sh "terraform apply -auto-approve -var 'kube_config=${KUBECONFIG}'"
                    }
                }
            }
        }
        stage('Secrets') {
            steps {
                withCredentials([file(credentialsId: 'k8s-kubeconfig', variable: 'K8S_AUTH_KUBECONFIG')]) {
                    dir('ansible') {
                        sh 'ansible-playbook -i inventory.ini secrets.yaml'
                    }
                }
            }
        }
        stage('Build & Push') {
            steps {
                script {
                    sh 'echo $DOCKER_CRED_PSW | docker login -u $DOCKER_CRED_USR --password-stdin'
                    sh "docker build -t $DOCKER_USER/mern-backend:latest ./backend"
                    sh "docker push $DOCKER_USER/mern-backend:latest"
                    sh "docker build --no-cache -t $DOCKER_USER/mern-frontend:latest ./frontend"
                    sh "docker push $DOCKER_USER/mern-frontend:latest"
                }
            }
        }
        // stage('Deploy') {
        //     steps {
        //         withCredentials([file(credentialsId: 'k8s-kubeconfig', variable: 'KUBECONFIG')]) {
        //             sh "helm upgrade --install mern-app ./k8s-helm --namespace mern-namespace --set backend.image=$DOCKER_USER/mern-backend --set frontend.image=$DOCKER_USER/mern-frontend --kubeconfig $KUBECONFIG"
        //         }
        //     }
        // }
        stage('Deploy') {
            steps {
                withCredentials([file(credentialsId: 'k8s-kubeconfig', variable: 'KUBECONFIG')]) {
                    // FIX: Delete the conflicting secret so Helm can assume ownership
                    sh "kubectl delete secret mern-secrets -n mern-namespace --kubeconfig $KUBECONFIG --ignore-not-found"
                    
                    // Proceed with Deploy
                    sh "helm upgrade --install mern-app ./k8s-helm --namespace mern-namespace --set backend.image=$DOCKER_USER/mern-backend --set frontend.image=$DOCKER_USER/mern-frontend --kubeconfig $KUBECONFIG"
                }
            }
        }
    }
}
