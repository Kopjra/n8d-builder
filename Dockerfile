FROM buildpack-deps:noble

ENV DEBIAN_FRONTEND=noninteractive

# Installing kubectl
RUN apt update && apt install -y apt-transport-https ca-certificates curl gnupg && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && chmod 644 /etc/apt/sources.list.d/kubernetes.list && apt update && apt install -y kubectl

# Add Docker's official GPG key:
RUN apt install -y ca-certificates curl && install -m 0755 -d /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && chmod a+r /etc/apt/keyrings/docker.asc
RUN tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
RUN apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Installing AWS CLI
#RUN apt-get install -y awscli
RUN apt-get install -y python3.12-venv && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

# Installing gcloud
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-cli -y && apt-get install -y google-cloud-cli-gke-gcloud-auth-plugin

# Installing kustomize (standalone binary)
RUN cd ~ && curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && mv kustomize /usr/local/bin/kustomize && chmod +x /usr/local/bin/kustomize

# Installing sops
RUN cd ~ && curl -LO https://github.com/getsops/sops/releases/download/v3.11.0/sops-v3.11.0.linux.amd64 && mv sops-v3.11.0.linux.amd64 /usr/local/bin/sops && chmod +x /usr/local/bin/sops

# Installing binaries
COPY ./bin/docker_image_pusher /bin/docker_image_pusher
COPY ./bin/kube_deployer /bin/kube_deployer
COPY ./bin/docker_registry_login /bin/docker_registry_login
COPY ./bin/gcp_run_deployer /bin/gcp_run_deployer
COPY ./bin/kube_getsecret /bin/kube_getsecret
COPY ./bin/kube_getconfig /bin/kube_getconfig
COPY ./bin/gke_deployer /bin/gke_deployer

CMD []
