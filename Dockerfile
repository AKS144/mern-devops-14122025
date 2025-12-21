FROM jenkins/jenkins:lts
USER root
RUN apt-get update && apt-get install -y docker.io python3-pip wget unzip curl git
# Terraform
RUN wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip && unzip terraform_1.6.0_linux_amd64.zip && mv terraform /usr/local/bin/
# Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl /usr/local/bin/
# Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# Ansible
RUN pip3 install ansible kubernetes --break-system-packages
RUN ansible-galaxy collection install community.kubernetes
RUN usermod -aG docker jenkins
USER jenkins
