FROM jenkins/jenkins:lts
USER root

# 1. Install Docker CLI
RUN apt-get update && \
    apt-get install -y docker.io python3-pip wget unzip

# 2. Install Ansible
RUN apt-get install -y ansible && \
    ansible-galaxy collection install community.kubernetes

# 3. Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip && \
    unzip terraform_1.6.0_linux_amd64.zip && \
    mv terraform /usr/local/bin/

# 4. Install Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 5. Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Grant Jenkins permission to run docker
RUN usermod -aG docker jenkins

USER jenkins