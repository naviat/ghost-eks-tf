# DEPLOY PRODUCTION READY GHOST BLOG TO AWS EKS BY TERRAFORM

EVERYTHING IN [deploy](./deploy) FOLDER. THANKS!

## Prerequisite

- `terraform` latest version.
- `awscli` latest with suitable account key.
- `helm`

## Objectives

At the end of this lab, I want to have the following setup:

- One EKS cluster in a region of choice. (It will be useful for company want to open and manage many region or many outpost)
- A production running Ghost blog and its respective database (MySQL for Ghost). These component will me orchestrated by helm in EKS for now (because AWS/DO cost problem 🐨🐨🐨). I will update version for use all AWS service managed later.
- Nginx Ingress Controller and CloudFlare with domain.
- The setup and deployment will be automated using Terraform.
- Integrate  github action to test, scan security.

> **Note**: This test is forcused on Managed node group. For Self Managed, Fargate and Windows Self Managed, I will update later (if needed :lying_face:).

![Architecture](/Ghost-blog.png "Architecture")
