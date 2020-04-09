FROM buildpack-deps:bionic

ENV DEBIAN_FRONTEND=noninteractive

# Should force a new build (cacheless)
# Not working except the first time
RUN date

# Installing kubectl
RUN apt-get update && apt-get install -y apt-transport-https
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN touch /etc/apt/sources.list.d/kubernetes.list
RUN echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl

# Installing Docker CLI (Docker inside Docker, yay!)
RUN apt-get install -y apt-transport-https ca-certificates curl software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
RUN apt-get update
RUN apt-get install -y docker-ce

# Installing AWS CLI
RUN apt-get install -y awscli

# Installing gcloud
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

# Installing kustomize
RUN cd ~ && wget https://github.com/kubernetes-sigs/kustomize/releases/download/v2.0.3/kustomize_2.0.3_linux_amd64 && mv kustomize_2.0.3_linux_amd64 /usr/bin/kustomize && chmod aug+x /usr/bin/kustomize

# Installing sops
RUN cd ~ && wget https://github.com/mozilla/sops/releases/download/3.2.0/sops-3.2.0.linux && mv sops-3.2.0.linux /usr/bin/sops && chmod aug+x /usr/bin/sops

# Installing binaries
COPY ./bin/docker_image_pusher /bin/docker_image_pusher
COPY ./bin/kube_deployer /bin/kube_deployer
COPY ./bin/docker_registry_login /bin/docker_registry_login
COPY ./bin/gcp_run_deployer /bin/gcp_run_deployer

CMD []
