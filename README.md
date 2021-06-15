# pipeline-config-petclinic

Configuration for the k8s-based ci/cd pipeline of the pet clinic app.

## Deployment model

![Deployment model of the petclinic](https://github.com/enrico2828/pipeline-config-petclinic/raw/main/petclinic-pipeline-setup-deployment-model.png "Deployment model of the petclinic pipeline")

## Setup process

![Deployment model of the petclinic](https://github.com/enrico2828/pipeline-config-petclinic/raw/main/petclinic-pipeline-setup-setup-process.png "Deployment model of the petclinic pipeline")


## CI/CD Pipeline process

![Deployment model of the petclinic](https://github.com/enrico2828/pipeline-config-petclinic/raw/main/petclinic-pipeline-setup-pipeline-process.png "Deployment model of the petclinic pipeline")


## Required Tools

* docker
* k3d
* kubectl 
* tkn
* argocd (optional)

## K3D initialization

`k3d registry create registry.localhost --port 47009`

`k3d cluster create --config k3d/config`

`mkdir -p .kube && k3d kubeconfig get petclinic-cluster > .kube/config`

`export KUBECONFIG=$(pwd)/.kube/config`

## Install Argo CD

`kubectl create namespace argocd && kubectl apply -n argocd -f argocd/`

`kubectl apply -n argocd -f argocd-app-loader/01-argocd-app-loader.yaml`

Login for argocd cli:

```
argocd login argocd.127.0.0.1.nip.io:80 \
       --insecure \
       --username admin \
       --password $(kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
```

## Install Secrets

To update the argocd petclinic apps we need to provide authentication for Github. We can use a github deploy key
for it. https://docs.github.com/en/developers/overview/managing-deploy-keys

Provide it as file "id_rsa" in secret "github-pipeline-config-petclinic-ssh-key"

```
apiVersion: v1
data:
  id_rsa: .......
kind: Secret
metadata:
  name: github-pipeline-config-petclinic-ssh-key
  namespace: default
```

Apply to cluster:

`kubectl apply -f secret-files/github-pipeline-config-petclinic-ssh-key-secret.yaml`

## Build application

`./startbuild-petclinic.sh`

## Try it yourself

You can just check out my repos and try it, but you will not be able to update the Argo apps in my github repo. 

You can fork those two repos:
* https://github.com/enrico2828/pipeline-config-petclinic
* https://github.com/enrico2828/spring-petclinic

Replace all reference to these with your own repos and add your secret to the k3d cluster as per the instruction above.