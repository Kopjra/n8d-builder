FROM buildpack-deps:focal

ENV DEBIAN_FRONTEND=noninteractive

# Installing kubectl
RUN apt-get update && apt-get install -y apt-transport-https
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN touch /etc/apt/sources.list.d/kubernetes.list
RUN echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl

# Installing Docker CLI (Docker inside Docker, yay!)
RUN apt-get install -y apt-transport-https ca-certificates curl software-properties-common

RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
# RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
RUN apt-get update
RUN apt-get install -y docker-ce

# Installing AWS CLI
#RUN apt-get install -y awscli
RUN apt-get install -y python3.8-venv
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN unzip awscli-bundle.zip
#run rm /usr/bin/aws
RUN /usr/bin/python3.8 awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Installing gcloud
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

# Installing kustomize
RUN cd ~ && wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_amd64.tar.gz && tar -xvf kustomize_v4.5.7_linux_amd64.tar.gz && mv kustomize /usr/bin/kustomize && chmod aug+x /usr/bin/kustomize

# Installing sops
RUN cd ~ && wget https://github.com/mozilla/sops/releases/download/3.2.0/sops-3.2.0.linux && mv sops-3.2.0.linux /usr/bin/sops && chmod aug+x /usr/bin/sops

# Installing binaries
COPY ./bin/docker_image_pusher /bin/docker_image_pusher
COPY ./bin/kube_deployer /bin/kube_deployer
COPY ./bin/docker_registry_login /bin/docker_registry_login
COPY ./bin/gcp_run_deployer /bin/gcp_run_deployer
COPY ./bin/kube_getsecret /bin/kube_getsecret
COPY ./bin/kube_getconfig /bin/kube_getconfig
COPY ./bin/gke_deployer /bin/gke_deployer

CMD []
