data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}


data "aws_availability_zones" "available" {}

locals {
  name   = "test-aurora-db-postgres"

  vpc_cidr = "10.10.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    Terraform = "terraform-aws-rds-aurora"
  }
}

################################################################################
# PostgreSQL Serverless v2
################################################################################

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "14.5"
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_rds_cluster" "teste_aurora_postgres" {
  engine                 = "aurora-postgresql"
  engine_version         =  "14.5"
  storage_encrypted      = true
  skip_final_snapshot = true
  master_username     = "employee"  # Substitua pelo nome de usuário desejado
  master_password     = "12345678"  # Substitua pela senha desejada
  db_subnet_group_name   = "development"
  backup_retention_period = 7  # Substitua pelo período de retenção do backup desejado em dias
  cluster_identifier = "auroraclusterteste"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  engine_mode        = "provisioned"

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "cluster_instance" {
  cluster_identifier = aws_rds_cluster.teste_aurora_postgres.cluster_identifier
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.teste_aurora_postgres.engine
  engine_version     = aws_rds_cluster.teste_aurora_postgres.engine_version
}


