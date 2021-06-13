# pipeline-config-petclinic

Configuration for the k8s-based ci/cd pipeline of the pet clinic app.

## Required Tools

* docker
* k3d
* kubectl 
* argo

## K3D initialization

`k3d registry create registry.localhost --port 47009`

`k3d cluster create --config k3d/config`

`mkdir -p .kube && k3d kubeconfig get petclinic-cluster > .kube/config`

`export KUBECONFIG=$(pwd)/.kube/config`

## Install Argo CD

```
kubectl create namespace argocd && \
kubectl apply -n argocd -f argocd/
```

`kubectl apply -n argocd -f argocd/05-argocd-app-loader.yaml`

Login for argocd cli:

```
argocd login argocd.127.0.0.1.nip.io:80 \
       --insecure \
       --username admin \
       --password $(kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
```


## Build application

`./startbuild-pletclinic.sh`
