# --- CLEANUP SECTION (Ignore errors if things don't exist) ---
Write-Host ">>> [1/6] CLEANING UP OLD CONTAINERS..." -ForegroundColor Cyan
try { docker rm -f jenkins-server } catch {}
try { docker network rm devops-net } catch {}

# --- CRITICAL SECTION (Stop if anything fails from here on) ---
$ErrorActionPreference = "Stop"

Write-Host ">>> [2/6] CREATING DOCKER NETWORK..." -ForegroundColor Cyan
docker network create devops-net
# Connect Minikube to this network so Jenkins can see it (Ignore if already connected)
try { docker network connect devops-net minikube } catch {}

Write-Host ">>> [3/6] GENERATING PORTABLE KUBECONFIG..." -ForegroundColor Cyan
# 1. Flatten config (embeds certificates)
kubectl config view --flatten --minify > kubeconfig_raw.yaml

# 2. Fix the Server URL for Docker Internal Network (Port 8443)
# We read the file, replace the IP/Port with 'https://minikube:8443', and save it.
$content = Get-Content .\kubeconfig_raw.yaml -Raw
$content = $content -replace 'server: https://.*', 'server: https://minikube:8443'
$content | Set-Content .\kubeconfig_fixed.yaml

Write-Host "    -> Config generated: kubeconfig_fixed.yaml" -ForegroundColor Green

Write-Host ">>> [4/6] CREATING CUSTOM JENKINS DOCKERFILE..." -ForegroundColor Cyan
# Create Dockerfile dynamically
$dockerfile = @"
FROM jenkins/jenkins:lts
USER root
# Install Basics
RUN apt-get update && apt-get install -y docker.io python3-pip wget unzip curl
# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip && \
    unzip terraform_1.6.0_linux_amd64.zip && \
    mv terraform /usr/local/bin/
# Install Kubectl
RUN curl -LO "https://dl.k8s.io/release/`$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/
# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# Install Ansible
RUN pip3 install ansible kubernetes --break-system-packages
# Grant Docker Permissions
RUN usermod -aG docker jenkins
USER jenkins
"@
$dockerfile | Out-File Dockerfile -Encoding ASCII

Write-Host ">>> [5/6] BUILDING JENKINS IMAGE (This may take 2-3 mins)..." -ForegroundColor Cyan
docker build -t my-devops-jenkins .

Write-Host ">>> [6/6] STARTING JENKINS..." -ForegroundColor Cyan
# We mount the FIXED config directly to /var/jenkins_home/.kube/config
# Using ${PWD} ensures the path works correctly on Windows PowerShell
docker run -d -p 9090:8080 -p 50000:50000 --name jenkins-server --network devops-net `
  -v //var/run/docker.sock:/var/run/docker.sock `
  -v "${PWD}\kubeconfig_fixed.yaml:/var/jenkins_home/.kube/config" `
  --user root `
  my-devops-jenkins

Write-Host "`n>>> DONE! Jenkins is running on http://localhost:9090" -ForegroundColor Green
Write-Host ">>> Retrieve Password using: docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword" -ForegroundColor Yellow