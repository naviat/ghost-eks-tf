# Provision an EKS Cluster

Terraform configuration files to provision an EKS cluster on AWS.

## Steps

Apply terraform:

```shell script
$ terraform init
$ terraform plan
$ terraform apply
```

Add kube config:

```shell script
$ aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

### Deploy and access Kubernetes Dashboard

- Deploy Kubernetes Metrics Server

```shell script
$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.2/components.yaml
```

- Deploy Kubernetes dashboard

```shell script
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
```

Now, create a proxy server that will allow you to navigate to the dashboard from the browser on your local machine. This will continue running until you stop the process by pressing `CTRL + C`.

```shell script
$ kubectl proxy
Starting to serve on 127.0.0.1:8001
```

Authen to Dashboard

```shell script
$ kubectl apply -f ./deploy/eks/simple-eks/kubernetes-dashboard-admin.rbac.yaml
$ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}')

```

Kubectl will make Dashboard available at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.

## Deploy Ghost blog

