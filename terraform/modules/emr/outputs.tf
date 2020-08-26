output "cluster_id" {
  value       = join("", aws_emr_cluster.default.*.id)
  description = "EMR cluster ID"
}

output "cluster_name" {
  value       = join("", aws_emr_cluster.default.*.name)
  description = "EMR cluster name"
}

output "master_public_dns" {
  value       = join("", aws_emr_cluster.default.*.master_public_dns)
  description = "Master public DNS"
}

output "master_security_group_id" {
  value       = join("", aws_security_group.master.*.id)
  description = "Master security group ID"
}

output "slave_security_group_id" {
  value       = join("", aws_security_group.slave.*.id)
  description = "Slave security group ID"
}

output "master_host" {
  value       = module.dns_master.hostname
  description = "Name of the cluster CNAME record for the master nodes in the parent DNS zone"
}