# pipeline-config-petclinic
Configuration for the k8s-based ci/cd pipeline of the pet clinic app.

## K3D initialization

k3d cluster create --config k3d/config

mkdir -p .kube && k3d kubeconfig get petclinic-cluster > .kube/config

export KUBECONFIG=$(pwd)/.kube/config

## Argo CD

kubectl create namespace argocd
kubectl apply -n argocd -f argocd/01-install.yaml \
                        -f argocd/02-ingress.yaml \
                        -f argocd/03-configmap.yaml \
                        -f argocd/04-rbac-configmap.yaml \
                        -f argocd/05-argocd-app-loader.yaml

