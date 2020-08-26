# output "public_subnet_cidrs" {
#   value       = module.subnets.public_subnet_cidrs
#   description = "Public subnet CIDRs"
# }

# output "private_subnet_cidrs" {
#   value       = module.subnets.private_subnet_cidrs
#   description = "Private subnet CIDRs"
# }

# output "vpc_cidr" {
#   value       = module.vpc.vpc_cidr_block
#   description = "VPC ID"
# }

# output "aws_key_pair_key_name" {
#   value       = module.aws_key_pair.key_name
#   description = "Name of SSH key"
# }

# output "aws_key_pair_public_key" {
#   value       = module.aws_key_pair.public_key
#   description = "Content of the generated public key"
# }

# output "aws_key_pair_public_key_filename" {
#   description = "Public Key Filename"
#   value       = module.aws_key_pair.public_key_filename
# }

# output "aws_key_pair_private_key_filename" {
#   description = "Private Key Filename"
#   value       = module.aws_key_pair.private_key_filename
# }

# output "s3_log_storage_bucket_domain_name" {
#   value       = module.s3_log_storage.bucket_domain_name
#   description = "FQDN of bucket"
# }

# output "s3_log_storage_bucket_id" {
#   value       = module.s3_log_storage.bucket_id
#   description = "Bucket Name (aka ID)"
# }

# output "s3_log_storage_bucket_arn" {
#   value       = module.s3_log_storage.bucket_arn
#   description = "Bucket ARN"
# }

# output "cluster_id" {
#   value       = module.emr_cluster.cluster_id
#   description = "EMR cluster ID"
# }

# output "cluster_name" {
#   value       = module.emr_cluster.cluster_name
#   description = "EMR cluster name"
# }

# output "cluster_master_public_dns" {
#   value       = module.emr_cluster.master_public_dns
#   description = "Master public DNS"
# }

# output "cluster_master_security_group_id" {
#   value       = module.emr_cluster.master_security_group_id
#   description = "Master security group ID"
# }

# output "cluster_slave_security_group_id" {
#   value       = module.emr_cluster.slave_security_group_id
#   description = "Slave security group ID"
# }

# output "cluster_master_host" {
#   value       = module.emr_cluster.master_host
#   description = "Name of the cluster CNAME record for the master nodes in the parent DNS zone"
# }