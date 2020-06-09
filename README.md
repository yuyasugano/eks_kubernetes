# AWS EKS test deployment with kubectl
 
## yaml file

1. `deployment.yaml` has 2 replicasets of nginx container tag 1.7.9
2. `service.yml` has a LoadBalancer type service for the app sample-app with the port 80
 
## run test
 
1. Build new cluster in EKS by using `eksctl` utility
```sh
eksctl create cluster --name sample-cluster --version 1.14 --region ap-northeast-1 --nodegroup-name sample-eks-workers --node-type t2.micro --nodes 2 --node-ami auto
eksctl get cluster
```
2. Confirm cluster status and node status
```sh
kubectl get svc
kubectl get componentstatuses
kubectl get nodes
kubectl get daemonSets --namespace=kube-system
kubectl get deployments --namespace=kube-system
kubectl get services --namespace=kube-system
```
3. Deployment and Service implementation with 2 replicasets for nginx:1.7.9
```sh
kubectl apply -f deployment.yaml
kubectl get pods -o wide
kubectl get deployments -o wide
kubectl apply -f service.yaml
kubectl get services -o wide
```
4. Scale out replicas to 3 in the deployment
```sh
kubectl scale deployment sample-deployment  --replicas 3
kubectl get replicasets
kubectl describe replicasets
```
5. Nginx image update to nginx:1.8.1 container from repo
```sh
kubectl set image deployment sample-deployment nginx-container=nginx:1.8.1
kubectl get replicasets
kubectl rollout undo deployment sample-deployment
```
6. Destroy the cluster in EKS by using `eksctl` utility
```sh
eksctl delete cluster --name sample-cluster
eksctl get cluster
```
 
This example shows how to demonstrate AWS EKS sample cluster with nginx container POD. This [implementation][imp] was the main source to refer.
 
[imp]: https://thinkit.co.jp/article/13289 
