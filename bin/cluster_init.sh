#!/bin/bash
# A useful script to initialize a new k8s cluster
EMAIL=email_address_here

helm install nginx-ingress stable/nginx-ingress --set controller.metrics.enabled=true
kubectl create namespace cert-manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml
cat <<EOF > letsencrypt-prod.yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: $EMAIL
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-account-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
kubectl apply -f letsencrypt-prod.yaml -n=cert-manager
