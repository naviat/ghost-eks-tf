# DEPLOY GHOST BLOG TO AWS EKS BY TERRAFORM IN PRODUCTION READY

## Prerequisite

- `terraform` latest version.
- `awscli` latest with suitable account key.

## Objectives

At the end of this lab, I want to have the following setup:

- One EKS cluster in a region of choice.
- A production running Ghost blog, Commento and their respective database (MySQL for Ghost, Posgres for Commento). These component will me orchestrated by helm in EKS for now (because AWS/DO cost problem 🐨🐨🐨). I will update version for use all AWS service managed later.
- Nginx Ingress Controller and CloudFlare with domain.
- The setup and deployment will be automated using Terraform.

## Architecture

