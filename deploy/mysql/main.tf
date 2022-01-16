provider "aws" {
  region = local.region
}

locals {
  name   = "homelab-${replace(basename(path.cwd), "_", "-")}"
  region = "ap-southeast-1"

  db_creds = jsondecode(
  aws_secretsmanager_secret_version.creds.secret_string
   )
  tags = {
    Owner       = "user"
    Environment = "production"
  }
}

################################################################################
# Supporting Resources
################################################################################
# Firstly we will create a random generated password which we will use in secrets.
resource "random_password" "master_password" {
  length = 10
  special = false
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.99.0.0/18"

  enable_dns_support   = true
  enable_dns_hostnames = true

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  tags = local.tags
}

################################################################################
# RDS Aurora Module
################################################################################

module "aurora" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = local.name
  engine         = "aurora-mysql"
  engine_version = "5.7.12"
  instance_class  = "db.t3.medium"
  instances = {
    1 = {}
    2 = {}
    3 = {}
  }

  vpc_id                 = module.vpc.vpc_id
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  create_db_subnet_group = false
  create_security_group  = true
  allowed_cidr_blocks    = module.vpc.private_subnets_cidr_blocks

  iam_database_authentication_enabled = true
  master_password                     = random_password.master_password.result
  create_random_password              = false

  apply_immediately   = true
  skip_final_snapshot = true

  db_parameter_group_name         = aws_db_parameter_group.homelab.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.homelab.id
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  tags = local.tags
}

resource "aws_db_parameter_group" "homelab" {
  name        = "${local.name}-aurora-db-57-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-db-57-parameter-group"
  tags        = local.tags
}

resource "aws_rds_cluster_parameter_group" "homelab" {
  name        = "${local.name}-aurora-57-cluster-parameter-group"
  family      = "aurora-mysql5.7"
  description = "${local.name}-aurora-57-cluster-parameter-group"
  tags        = local.tags
}

# Now create secret and secret versions for database master account 
resource "aws_secretsmanager_secret" "master_account_creds" {
   name = "master_account_creds"
}

resource "aws_secretsmanager_secret_version" "creds" {
  secret_id = aws_secretsmanager_secret.master_account_creds.id
  secret_string = <<EOF
   {
    "database_password": "${random_password.master_password.result}",
    "database_host": ${module.aurora.cluster_endpoint}
   }
EOF
}

# Lets import the Secrets which got created recently and store it so that we can use later. 

data "aws_secretsmanager_secret" "master_account_creds" {
  arn = aws_secretsmanager_secret.master_account_creds.arn
}

# data "aws_secretsmanager_secret_version" "creds" {
#   secret_id = data.aws_secretsmanager_secret.master_account_creds.arn
# }