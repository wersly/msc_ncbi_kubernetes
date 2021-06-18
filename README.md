# About
This repo covers task 2 (the kubernetes deployment) on the codility exam - or at least, what I can remember of task 2, as I forgot to capture the full task description in my notes before submitting the exam! D:  ...so it goes. Here is my best approximation in redoing task 2.

In order to get my own kubernetes deployments going, I needed to set up a toy cluster on AWS. The terraform code outlining how that was done may be found in `aws/`.

I've included here 3 YAML files outlining different kubernetes actions:
1. `task_2.yaml.submitted`. This was the file that I initially submitted via codility.
2. `basic_pod.yaml`. This is a basic kubernetes file which deploys a tomcat webserver via a single Pod. I wrote and tested this just to focus on the basics.
3. `task-2-deployment.yaml`. This is my re-attempt at task 2, using the kubernetes Deployment declaration and the liveness/readiness probes outlined in task 2. I am using the `bitnami/tomcat` container as a deployable stand-in for the `hub.example.com/shop-backend;1.0.0` container, updating the ports and health check endpoints in accord with tomcat's requirements.

Below are my notes outlining the process from setting up the cluster, to running the deployment and checking things out. You can follow along at home if you wish, though the commands assume you have a few things already set up:
- `awscli` / an AWS account, and an assumable IAM user or role with API key access
- `kubectl`
- `terraform`

# Create EKS cluster
```bash
cd aws
terraform plan
terraform apply
```

# Attach local kubectl to provisioned EKS cluster
```bash
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_id)
```

# Task 2 Deployment

```bash
# create the deployment
kubectl create -f task-2-deployment.yaml

# monitor deploy progress
kubectl rollout status deployments tomcat

# tail the logs for the last pod in the replicaset; just see how the server's doing
kubectl get pods | tail -n1 | awk '{print $1}' | xargs kubectl logs -f

# get deployments
kubectl get deployments

# describe deployment
kubectl describe deployments tomcat

# expose the whole deployment via LB
kubectl expose deployment tomcat --type=LoadBalancer --name=tomcat

# check on the service
kubectl get services tomcat

# get the service address and check on it via curl
# NOTE: it will take ~3 or so minutes from the `expose` command until the load balancer is properly connected and routing to the cluster
curl http://$(kubectl get services tomcat | tail -n1 | awk '{print $4}'):8080

# apply changes via the deployment file, should any occur
# kubectl apply -f task-2-deployment.yaml
```

# Teardown Procedure
```bash
kubectl delete svc tomcat
kubectl delete -f task-2-deployment.yaml
cd aws
terraform destroy
```

# An experiment in intentionally failing the livenessProbe / testing the livenessProbe
Assume our tomcat deployment uses the following livenessProbe:
```yaml
livenessProbe:
 httpGet:
  path: /does_not_exist
  port: 8080
initialDelaySeconds: 10
```
That is, we make a deployment that intentionally fails since it health checks against a non-existent path. This probe will fail after the default failureThreshold of 3. What does that look like from kubectl?
```bash
# 5 minutes after deploying
> kubectl get pods
NAME                      READY   STATUS             RESTARTS   AGE
tomcat-7d7c4d9856-8w9qk   0/1     CrashLoopBackOff   6          6m26s
tomcat-7d7c4d9856-bgz47   0/1     CrashLoopBackOff   6          6m26s
tomcat-7d7c4d9856-mms4g   0/1     CrashLoopBackOff   5          6m12s
```
Cool! It looks like the liveness probe is working correctly.

# Basic Pod Test
```bash
# get nodes
kubectl get nodes

# describe node in greater detail
kubectl describe nodes <node name from `kubectl get nodes`>

# launch the basic pod example
kubectl apply -f basic-pod.yaml

# pod status
kubectl get pods

# get pod details
kubectl describe pods tomcat

# expose the pod via public IP
kubectl expose pod tomcat --type=LoadBalancer --name=tomcat

# get the public IP assigned via the service
kubectl get services tomcat

# delete the exposed service when you're done with it
kubectl delete svc tomcat

# delete a pod
kubectl delete -f basic-pod.yaml
```

# kubectl cheatsheet
https://kubernetes.io/docs/reference/kubectl/cheatsheet/
