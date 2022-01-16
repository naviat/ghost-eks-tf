# Step to deploy GHOST blog

1. Deploy the mysql from [mysql folder](./mysql)

```shell script
$ tf init

$ tf plan 

$ tf apply -auto-approve
```

2. Deploy EKS cluster with add-ons from [eks/advanced](./eks/advanced) then install external secrets by Helm

```shell script
$ tf init

$ tf plan 

$ tf apply -auto-approve

$ helm repo add external-secrets https://external-secrets.github.io/kubernetes-external-secrets/
$ helm install external-secrets external-secrets/kubernetes-external-secrets
```

3. Deploy Ghost blog by Helm

```
helm install ghost-blog ./ghost-blog
```