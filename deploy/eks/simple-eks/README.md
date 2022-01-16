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


## Deploy alb-controller

```
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(aws configure get region)
export AZS=($(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output text --region $AWS_REGION))

if [ ! -x ${LBC_VERSION} ]
  then
    tput setaf 2; echo '${LBC_VERSION} has been set.'
  else
    tput setaf 1;echo '${LBC_VERSION} has NOT been set.'
fi

## install alb controller policy

curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.0/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

## Create a IAM role and ServiceAccount

eksctl create iamserviceaccount \
  --cluster eksworkshop-eksctl \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master

helm repo add eks https://aws.github.io/eks-charts

helm upgrade -i aws-load-balancer-controller \
    eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=eksworkshop-eksctl \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set image.tag="${LBC_VERSION}"


```
### Create IAM OIDC provider

```
eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster eksworkshop-eksctl \
    --approve
```

## Deploy Ghost blog

