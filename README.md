# DEPLOY PRODUCTION READY GHOST BLOG TO AWS EKS BY TERRAFORM 

## Prerequisite

- `terraform` latest version.
- `awscli` latest with suitable account key.

## Objectives

At the end of this lab, I want to have the following setup:

- One EKS cluster in a region of choice.
- A production running Ghost blog and its respective database (MySQL for Ghost). These component will me orchestrated by helm in EKS for now (because AWS/DO cost problem 🐨🐨🐨). I will update version for use all AWS service managed later.
- Nginx Ingress Controller and CloudFlare with domain.
- The setup and deployment will be automated using Terraform.

> **Note**: This test is forcus on Managed node and Self Managed Node Group. For Windows Self Managed and EMR Node group, I will be update later (if needed :lying_face:).

## Architecture

