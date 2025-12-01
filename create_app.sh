#!/bin/bash
# Script to create an Ansible app role skeleton with ingress
# Usage: ./create_app_role.sh <role_name>

if [ -z "$1" ]; then
  echo "Usage: $0 <role_name>"
  exit 1
fi

ROLE_NAME="$1"
ROLE_DIR="roles/$ROLE_NAME"

# Create directories
mkdir -p "$ROLE_DIR/tasks"
mkdir -p "$ROLE_DIR/templates"
mkdir -p "$ROLE_DIR/defaults"

cat > "$ROLE_DIR/tasks/main.yaml" <<EOF
- name: Ensure namespace exists
  kubernetes.core.k8s:
    api_version: v1
    kind: Namespace
    name: "{{ namespace }}"
    state: present
    kubeconfig: /etc/rancher/k3s/k3s.yaml

- name: Apply deployment
  kubernetes.core.k8s:
    state: present
    template: "deployment.j2"
    kubeconfig: /etc/rancher/k3s/k3s.yaml

- name: Apply service
  kubernetes.core.k8s:
    state: present
    template: "service.j2"
    kubeconfig: /etc/rancher/k3s/k3s.yaml

- name: Apply ingress
  kubernetes.core.k8s:
    state: present
    template: "ingress.j2"
    kubeconfig: /etc/rancher/k3s/k3s.yaml
EOF

cat > "$ROLE_DIR/defaults/main.yaml" <<EOF
---
app_name: $ROLE_NAME
namespace: $ROLE_NAME
replicas: 1
image: nginx:latest
service_port: 80
host: $ROLE_NAME.d.32123.pl
EOF

cat > "$ROLE_DIR/templates/deployment.j2" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ app_name }}
  namespace: {{ namespace }}
spec:
  replicas: {{ replicas }}
  selector:
    matchLabels:
      app: {{ app_name }}
  template:
    metadata:
      labels:
        app: {{ app_name }}
    spec:
      containers:
      - name: {{ app_name }}
        image: {{ image }}
        ports:
        - containerPort: {{ service_port }}
EOF

cat > "$ROLE_DIR/templates/service.j2" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: {{ app_name }}
  namespace: {{ namespace }}
spec:
  selector:
    app: {{ app_name }}
  ports:
  - protocol: TCP
    port: {{ service_port }}
    targetPort: {{ service_port }}
EOF

cat > "$ROLE_DIR/templates/ingress.j2" <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ app_name }}-ingress
  namespace: {{ namespace }}
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-cloudflare"
spec:
  ingressClassName: traefik
  tls:
    - hosts:
        - {{ host }}
      secretName: wildcard-cert-tls
  rules:
    - host: {{ host }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ app_name }}
                port:
                  number: 80
EOF