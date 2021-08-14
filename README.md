# GitOps CI/CD Pipeline with ArgoCD and Tekton

This repository contains configuration for a k8s-based ci/cd pipeline of the Spring petclinic app.

It is meant to demonstrate how we can shape a kubernetes native ci/cd pipeline. The goal was to create a showcase
that anyone can check out on his local machine and run. All you need is Docker for the k3s based kubernetets cluster
provided by k3d. However, everything should run just fine on any kubernetes cluster. But you will need to make 
adjustment with respect to usage of the docker registry and networking. 

## Deployment model

The idea is to use k3d and docker to quickly provide a kubernetes cluster on a local machine. From there, we deploy
and run everything in kubernetes.

![Deployment model of the petclinic](https://github.com/enrico2828/pipeline-config-petclinic/raw/main/petclinic-pipeline-setup-deployment-model.png "Deployment model of the petclinic pipeline")

You can access deployed tools on:
* http://argocd.127.0.0.1.nip.io
* http://tekton.127.0.0.1.nip.io
* http://petclinic-staging.127.0.0.1.nip.io
* http://petclinic-production.127.0.0.1.nip.io


## Setup process

Here an overview of the steps to set up the environment:

![Deployment model of the petclinic](https://github.com/enrico2828/pipeline-config-petclinic/raw/main/petclinic-pipeline-setup-setup-process.png "Deployment model of the petclinic pipeline")


## CI/CD Pipeline process

Once the environment is started, this is the CI/CD process that can be kicked off:

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

## Deploy Argo CD

`kubectl create namespace argocd && kubectl apply -n argocd -f argocd/`

`kubectl apply -n argocd -f argocd-app-loader/01-argocd-app-loader.yaml`

Login for argocd cli if you want to use the command line client:

```
argocd login argocd.127.0.0.1.nip.io:80 \
       --insecure \
       --username admin \
       --password $(kubectl get secrets -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
```

## Install Secrets

To update the argocd petclinic apps we need to provide authentication for the Github repo with the configuration files. 
We can use a github deploy key for it. https://docs.github.com/en/developers/overview/managing-deploy-keys

Provide it as file "id_rsa" in secret "github-pipeline-config-petclinic-ssh-key"

```
apiVersion: v1
kind: ConfigMap
data:
  id_rsa: .......
kind: Secret
metadata:
  name: github-pipeline-config-petclinic-ssh-key
  namespace: default
```

Apply to cluster:

`kubectl apply -f secret-files/github-pipeline-config-petclinic-ssh-key-secret.yaml`

## Start the CI/CD pipeline

`./startbuild-petclinic.sh`

It will output instructions to watch the build or simply go to the dasboard.

## Erase your traces

Since everything is running in Docker, removing the docker containers will clean up everything.

`k3d cluster delete petclinic-cluster`

`k3d registry delete k3d-registry.localhost`

## Try it yourself

You can just check out my repos and try it, but you will not be able to update the Argo apps in my github repo. 

You can fork those two repos:
* https://github.com/enrico2828/pipeline-config-petclinic
* https://github.com/enrico2828/spring-petclinic

Replace all reference to these with your own repos and add your secret to the k3d cluster as per the instruction above.

## Optional: Use Nexus for local caching

If you want to destroy and rebuild the cluster often, this will generate a lot of traffic. To deploy everything,
more than 2,5 GB of docker images has to be downloaded. Therefore, it can be useful to use a local repository cache like
Nexus.

You can start a local nexus instance from `nexus` directory: 

`docker-compose up -d`

Data will be persisted in the `data` directory on the host. 

For now, repositories need to be set up manually. Go to nexus on `http:\\localhost:8081`. The admin password can be found
in `nexus\data`. 

Add two docker proxies
* quay.io on port 5004
* docker.io on port 5003
* gcr.io on port 5002

Make sure to enable anonymous access and the docker realm.

Also, initialize the k3d cluster with the adjusted config that makes k3d use the local docker registry:

`k3d cluster create --config k3d/config_nexus`

Voila! Now all your kubernetes images will be proxied through Nexus.
