# AWS EKS test deployment with eksctl and kubectl
 
## yaml file

1. `deployment.yaml` has 2 replicasets of nginx container tag 1.7.9
2. `service.yml` has a LoadBalancer type service for the app sample-app with the port 80
3. `ds_sample.yaml` has 2 replicasets to deploy nginx in each node as a daemonSet
4. `statefulset_sample.yaml` is the same set of the deployment but has persistent volume
5. `job_sample.yaml` is a one-time sleep batch job with centos container
6. `cronjob_sample.yaml` runs a job periodically in specified schedule
 
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
kubectl scale deployment sample-deployment --replicas 3
kubectl get replicasets
kubectl describe replicasets
```
5. Nginx image update to nginx:1.8.1 container from repo
```sh
kubectl set image deployment sample-deployment nginx-container=nginx:1.8.1
kubectl get replicasets
kubectl rollout undo deployment sample-deployment
```
6. DaemonSets and Statefulset implementation with 2 replicas
```sh
kubectl apply -f ds_sample.yaml
kubectl get daemonSets
kubectl apply -f statefulset_sample.yaml
kubectl get statefulset
kubectl exec -it sample-statefulset-0 touch /usr/share/nginx/html/sample.html
kubectl exec -it sample-statefulset-0 ls /usr/share/nginx/html
```
7. Job and Cronjob sample test with centos container
```sh
kubectl apply -f job_sample.yaml
kubectl get jobs
kubectl apply -f cronjob_sample.yaml
kubectl get cronjob
```
8. Service ClusterIP, NodePort, ExternalIP, ExternalName and Headless
```sh
kubectl apply -f deployment.yaml
kubectl apply -f clusterip_sample.yml
./hostname.sh
kubectl run --image=centos:7 --restart=Never --rm  -i testpod -- curl -s http://sample-clusterip:8080
kubectl run --image=centos:6 --restart=Never --rm -i testpod -- dig sample-clusterip.default.svc.cluster.local
kubectl apply -f clusterip_multi_sample.yaml
kubectl get node -o custom-columns="NAME:{metadata.name},IP:{status.addresses[].address}"
kubectl apply -f externalip_sample.yaml
kubectl apply -f nodeport_sample.yaml
kubectl apply -f nodeport_local_sample.yaml
kubectl apply -f headless_sample.yaml
kubectl apply -f externalname_sample.yaml
```
9. Ingress and Ingress Controller
- Ingress resource with external load-balancer via NodePort
```sh
cd ingress
cat << _EOF_ | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-ingress-apps
spec:
  replicas: 1
  selector:
    matchLabels:
      ingress-app: sample
  template:
    metadata:
      labels:
        ingress-app: sample
    spec:
      containers:
        - name: nginx-container
          image: zembutsu/docker-sample-nginx:1.0
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: svc1
spec:
  type: NodePort
  ports:
    - name: "http-port"
      protocol: "TCP"
      port: 8888
      targetPort: 80
  selector:
    ingress-app: sample
_EOF_
  
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=sample.example.com"
kubectl create secret tls tls-sample --key /tmp/tls.key --cert /tmp/tls.crt
kubectl apply -f ingress_sample.yaml
```
- Ingress with Nginx Ingress Controller within a cluster
```sh
kubectl apply -f deployment_http.yaml
kubectl apply -f service_http.yaml
kubectl apply -f ingress_controller_sample.yaml
kubectl apply -f service_ingress_controller.yaml 
```
10. Destroy the cluster in EKS by using `eksctl` utility
```sh
eksctl delete cluster --name sample-cluster --wait
eksctl get cluster
```
 
This example shows how to demonstrate AWS EKS sample cluster with nginx container POD. This [implementation][imp] was the main source to refer.
 
[imp]: https://thinkit.co.jp/article/13289 
