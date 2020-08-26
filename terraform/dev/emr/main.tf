terraform {
  backend "s3" {
    bucket         = "terraform-wolt-aws-analytics-dev"
    key            = "emr/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-wolt-aws-analytics-dev"
    role_arn       = "arn:aws:iam::262402974952:role/AWSAdmin"
  }
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.43"
  assume_role {
    role_arn = "arn:aws:iam::262402974952:role/AWSAdmin"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "terraform-wolt-aws-analytics-dev"
    key            = "dev/vpc/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-wolt-aws-analytics-dev"
    role_arn       = "arn:aws:iam::262402974952:role/AWSAdmin"
  }
}

data "aws_route_table" "rt" {
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnets[0]
}

data "aws_security_groups" "sgs" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.vpc.outputs.vpc_id]
  }
}

module "s3_log_storage" {
  source        = "git::https://github.com/cloudposse/terraform-aws-s3-log-storage.git?ref=tags/0.13.1"
  region        = var.region
  namespace     = var.namespace
  stage         = var.stage
  name          = var.name
  attributes    = ["logs"]
  force_destroy = true
}

module "aws_key_pair" {
  source              = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=tags/0.13.1"
  namespace           = var.namespace
  stage               = var.stage
  name                = var.name
  attributes          = ["ssh", "key"]
  ssh_public_key_path = var.ssh_public_key_path
  generate_ssh_key    = var.generate_ssh_key
}

module "emr_cluster" {
  source                                         = "../../modules/emr"
  namespace                                      = var.namespace
  stage                                          = var.stage
  name                                           = var.name
  master_allowed_security_groups                 = [data.aws_security_groups.sgs.ids[0]]
  slave_allowed_security_groups                  = [data.aws_security_groups.sgs.ids[0]]
  region                                         = var.region
  vpc_id                                         = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_id                                      = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  route_table_id                                 = data.aws_route_table.rt.route_table_id
  subnet_type                                    = "private"
  ebs_root_volume_size                           = var.ebs_root_volume_size
  visible_to_all_users                           = var.visible_to_all_users
  release_label                                  = var.release_label
  applications                                   = var.applications
  configurations_json                            = var.configurations_json
  core_instance_group_instance_type              = var.core_instance_group_instance_type
  core_instance_group_instance_count             = var.core_instance_group_instance_count
  core_instance_group_ebs_size                   = var.core_instance_group_ebs_size
  core_instance_group_ebs_type                   = var.core_instance_group_ebs_type
  core_instance_group_ebs_volumes_per_instance   = var.core_instance_group_ebs_volumes_per_instance
  core_instance_group_bid_price                  = var.core_instance_group_bid_price
  master_instance_group_instance_type            = var.master_instance_group_instance_type
  master_instance_group_instance_count           = var.master_instance_group_instance_count
  master_instance_group_ebs_size                 = var.master_instance_group_ebs_size
  master_instance_group_ebs_type                 = var.master_instance_group_ebs_type
  master_instance_group_ebs_volumes_per_instance = var.master_instance_group_ebs_volumes_per_instance
  create_task_instance_group                     = var.create_task_instance_group
  log_uri                                        = format("s3://%s", module.s3_log_storage.bucket_id)
  key_name                                       = module.aws_key_pair.key_name
}
