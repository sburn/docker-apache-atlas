module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

module "label_emr" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("emr")))
}

module "label_ec2" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("ec2")))
}

module "label_ec2_autoscaling" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("ec2", "autoscaling")))
}

module "label_master" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("master")))
}

module "label_slave" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("slave")))
}

module "label_core" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("core")))
}

module "label_task" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled && var.create_task_instance_group
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("task")))
}

module "label_master_managed" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("master", "managed")))
}

module "label_slave_managed" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("slave", "managed")))
}

module "label_service_managed" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  enabled    = var.enabled
  context    = module.label.context
  attributes = compact(concat(module.label.attributes, list("service", "managed")))
}

/*
NOTE on EMR-Managed security groups: These security groups will have any missing inbound or outbound access rules added and maintained by AWS,
to ensure proper communication between instances in a cluster. The EMR service will maintain these rules for groups provided
in emr_managed_master_security_group and emr_managed_slave_security_group;
attempts to remove the required rules may succeed, only for the EMR service to re-add them in a matter of minutes.
This may cause Terraform to fail to destroy an environment that contains an EMR cluster, because the EMR service does not revoke rules added on deletion,
leaving a cyclic dependency between the security groups that prevents their deletion.
To avoid this, use the revoke_rules_on_delete optional attribute for any Security Group used in
emr_managed_master_security_group and emr_managed_slave_security_group.
*/

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-sg-specify.html
# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html
# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html

resource "aws_security_group" "managed_master" {
  count                  = var.enabled ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = module.label_master_managed.id
  description            = "EmrManagedMasterSecurityGroup"
  tags                   = module.label_master_managed.tags

  # EMR will update "ingress" and "egress" so we ignore the changes here
  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_security_group_rule" "managed_master_egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = join("", aws_security_group.managed_master.*.id)
}

resource "aws_security_group" "managed_slave" {
  count                  = var.enabled ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = module.label_slave_managed.id
  description            = "EmrManagedSlaveSecurityGroup"
  tags                   = module.label_slave_managed.tags

  # EMR will update "ingress" and "egress" so we ignore the changes here
  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_security_group_rule" "managed_slave_egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = join("", aws_security_group.managed_slave.*.id)
}

resource "aws_security_group" "managed_service_access" {
  count                  = var.enabled && var.subnet_type == "private" ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = module.label_service_managed.id
  description            = "EmrManagedServiceAccessSecurityGroup"
  tags                   = module.label_service_managed.tags

  # EMR will update "ingress" and "egress" so we ignore the changes here
  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_security_group_rule" "managed_service_access_egress" {
  count             = var.enabled && var.subnet_type == "private" ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = join("", aws_security_group.managed_service_access.*.id)
}

resource "aws_security_group_rule" "managed_service_access_ingress" {
  count                    = var.enabled ? length(aws_security_group.managed_master) : 0
  description              = "Allow ingress traffic to port 9443 from master SGs"
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.managed_master[count.index].id
  security_group_id        = join("", aws_security_group.managed_service_access.*.id)
}

# Specify additional master and slave security groups
resource "aws_security_group" "master" {
  count                  = var.enabled ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = module.label_master.id
  description            = "Allow inbound traffic from Security Groups and CIDRs for masters. Allow all outbound traffic"
  tags                   = module.label_master.tags
}

resource "aws_security_group_rule" "master_ingress_security_groups" {
  count                    = var.enabled ? length(var.master_allowed_security_groups) : 0
  description              = "Allow inbound traffic from Security Groups"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.master_allowed_security_groups[count.index]
  security_group_id        = join("", aws_security_group.master.*.id)
}

resource "aws_security_group_rule" "master_ingress_cidr_blocks" {
  count             = var.enabled && length(var.master_allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.master_allowed_cidr_blocks
  security_group_id = join("", aws_security_group.master.*.id)
}

resource "aws_security_group_rule" "master_egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.master.*.id)
}

resource "aws_security_group" "slave" {
  count                  = var.enabled ? 1 : 0
  revoke_rules_on_delete = true
  vpc_id                 = var.vpc_id
  name                   = module.label_slave.id
  description            = "Allow inbound traffic from Security Groups and CIDRs for slaves. Allow all outbound traffic"
  tags                   = module.label_slave.tags
}

resource "aws_security_group_rule" "slave_ingress_security_groups" {
  count                    = var.enabled ? length(var.slave_allowed_security_groups) : 0
  description              = "Allow inbound traffic from Security Groups"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = var.slave_allowed_security_groups[count.index]
  security_group_id        = join("", aws_security_group.slave.*.id)
}

resource "aws_security_group_rule" "slave_ingress_cidr_blocks" {
  count             = var.enabled && length(var.slave_allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.slave_allowed_cidr_blocks
  security_group_id = join("", aws_security_group.slave.*.id)
}

resource "aws_security_group_rule" "slave_egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.slave.*.id)
}

/*
Allows Amazon EMR to call other AWS services on your behalf when provisioning resources and performing service-level actions.
This role is required for all clusters.
https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
*/
data "aws_iam_policy_document" "assume_role_emr" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com", "application-autoscaling.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "emr" {
  count              = var.enabled ? 1 : 0
  name               = module.label_emr.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role_emr.*.json)
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
resource "aws_iam_role_policy_attachment" "emr" {
  count      = var.enabled ? 1 : 0
  role       = join("", aws_iam_role.emr.*.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

/*
Application processes that run on top of the Hadoop ecosystem on cluster instances use this role when they call other AWS services.
For accessing data in Amazon S3 using EMRFS, you can specify different roles to be assumed based on the user or group making the request,
or on the location of data in Amazon S3.
This role is required for all clusters.
https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
*/
data "aws_iam_policy_document" "assume_role_ec2" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2" {
  count              = var.enabled ? 1 : 0
  name               = module.label_ec2.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role_ec2.*.json)
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
resource "aws_iam_role_policy_attachment" "ec2" {
  count      = var.enabled ? 1 : 0
  role       = join("", aws_iam_role.ec2.*.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2" {
  count = var.enabled ? 1 : 0
  name  = join("", aws_iam_role.ec2.*.name)
  role  = join("", aws_iam_role.ec2.*.name)
}

/*
Allows additional actions for dynamically scaling environments. Required only for clusters that use automatic scaling in Amazon EMR.
This role is required for all clusters.
https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
*/
resource "aws_iam_role" "ec2_autoscaling" {
  count              = var.enabled ? 1 : 0
  name               = module.label_ec2_autoscaling.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role_emr.*.json)
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
resource "aws_iam_role_policy_attachment" "ec2_autoscaling" {
  count      = var.enabled ? 1 : 0
  role       = join("", aws_iam_role.ec2_autoscaling.*.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
}

# This dummy bootstrap action is needed because of terraform bug https://github.com/terraform-providers/terraform-provider-aws/issues/12683
# When javax.jdo.option.ConnectionPassword is used in configuration_json then every plan will result in force recreation of EMR cluster.
# To mitigate this issue dummy bootstrap action `echo` was introduced. It is executed with an argument of a hash generated from configuration.
# This in tandem with lifecycle ignore_changes for `configurations_json` will only trigger EMR recreation when hash of configuration will change.
locals {
  bootstrap_action = concat(
    [{
      path = "file:/bin/echo",
      name = "Dummy bootstrap action to prevent EMR cluster recration when configuration_json has parameter javax.jdo.option.ConnectionPassword.",
      args = [md5(jsonencode(var.configurations_json))]
    }],
    var.bootstrap_action
  )

  kerberos_attributes = {
    ad_domain_join_password              = var.kerberos_ad_domain_join_password
    ad_domain_join_user                  = var.kerberos_ad_domain_join_user
    cross_realm_trust_principal_password = var.kerberos_cross_realm_trust_principal_password
    kdc_admin_password                   = var.kerberos_kdc_admin_password
    realm                                = var.kerberos_realm
  }

}

resource "aws_emr_cluster" "default" {
  count         = var.enabled ? 1 : 0
  name          = module.label.id
  release_label = var.release_label

  # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-sg-specify.html
  ec2_attributes {
    key_name                          = var.key_name
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = join("", aws_security_group.managed_master.*.id)
    emr_managed_slave_security_group  = join("", aws_security_group.managed_slave.*.id)
    service_access_security_group     = var.subnet_type == "private" ? join("", aws_security_group.managed_service_access.*.id) : null
    instance_profile                  = join("", aws_iam_instance_profile.ec2.*.arn)
    additional_master_security_groups = join("", aws_security_group.master.*.id)
    additional_slave_security_groups  = join("", aws_security_group.slave.*.id)
  }

  termination_protection            = var.termination_protection
  keep_job_flow_alive_when_no_steps = var.keep_job_flow_alive_when_no_steps
  ebs_root_volume_size              = var.ebs_root_volume_size
  custom_ami_id                     = var.custom_ami_id
  visible_to_all_users              = var.visible_to_all_users

  applications = var.applications

  core_instance_group {
    name           = module.label_core.id
    instance_type  = var.core_instance_group_instance_type
    instance_count = var.core_instance_group_instance_count

    ebs_config {
      size                 = var.core_instance_group_ebs_size
      type                 = var.core_instance_group_ebs_type
      iops                 = var.core_instance_group_ebs_iops
      volumes_per_instance = var.core_instance_group_ebs_volumes_per_instance
    }

    bid_price          = var.core_instance_group_bid_price
    autoscaling_policy = var.core_instance_group_autoscaling_policy
  }

  master_instance_group {
    name           = module.label_master.id
    instance_type  = var.master_instance_group_instance_type
    instance_count = var.master_instance_group_instance_count
    bid_price      = var.master_instance_group_bid_price

    ebs_config {
      size                 = var.master_instance_group_ebs_size
      type                 = var.master_instance_group_ebs_type
      iops                 = var.master_instance_group_ebs_iops
      volumes_per_instance = var.master_instance_group_ebs_volumes_per_instance
    }
  }

  scale_down_behavior    = var.scale_down_behavior
  additional_info        = var.additional_info
  security_configuration = var.security_configuration

  dynamic "bootstrap_action" {
    for_each = local.bootstrap_action
    content {
      path = bootstrap_action.value.path
      name = bootstrap_action.value.name
      args = bootstrap_action.value.args
    }
  }

  dynamic "kerberos_attributes" {
    for_each = var.kerberos_enabled ? [local.kerberos_attributes] : []

    content {
      ad_domain_join_password              = kerberos_attributes.value.ad_domain_join_password
      ad_domain_join_user                  = kerberos_attributes.value.ad_domain_join_user
      cross_realm_trust_principal_password = kerberos_attributes.value.cross_realm_trust_principal_password
      kdc_admin_password                   = kerberos_attributes.value.kdc_admin_password
      realm                                = kerberos_attributes.value.realm
    }
  }

  configurations_json = var.configurations_json

  log_uri = var.log_uri

  service_role     = join("", aws_iam_role.emr.*.arn)
  autoscaling_role = join("", aws_iam_role.ec2_autoscaling.*.arn)

  tags = module.label.tags

  # configurations_json changes are ignored because of terraform bug. Configuration changes are applied via local.bootstrap_action.
  lifecycle {
    ignore_changes = [kerberos_attributes, step, configurations_json]
  }
}

# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html
# https://www.terraform.io/docs/providers/aws/r/emr_instance_group.html
resource "aws_emr_instance_group" "task" {
  count      = var.enabled && var.create_task_instance_group ? 1 : 0
  name       = module.label_task.id
  cluster_id = join("", aws_emr_cluster.default.*.id)

  instance_type  = var.task_instance_group_instance_type
  instance_count = var.task_instance_group_instance_count

  ebs_config {
    size                 = var.task_instance_group_ebs_size
    type                 = var.task_instance_group_ebs_type
    iops                 = var.task_instance_group_ebs_iops
    volumes_per_instance = var.task_instance_group_ebs_volumes_per_instance
  }

  bid_price          = var.task_instance_group_bid_price
  ebs_optimized      = var.task_instance_group_ebs_optimized
  autoscaling_policy = var.task_instance_group_autoscaling_policy
}

module "dns_master" {
  source  = "git::https://github.com/cloudposse/terraform-aws-route53-cluster-hostname.git?ref=tags/0.5.0"
  enabled = var.enabled && var.zone_id != null && var.zone_id != "" ? true : false
  name    = var.master_dns_name != null && var.master_dns_name != "" ? var.master_dns_name : "emr-master-${var.name}"
  zone_id = var.zone_id
  records = coalescelist(aws_emr_cluster.default.*.master_public_dns, [""])
}

# https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html
# https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-clusters-in-a-vpc.html
resource "aws_vpc_endpoint" "vpc_endpoint_s3" {
  count           = var.enabled && var.subnet_type == "private" && var.create_vpc_endpoint_s3 ? 1 : 0
  vpc_id          = var.vpc_id
  service_name    = format("com.amazonaws.%s.s3", var.region)
  auto_accept     = true
  route_table_ids = [var.route_table_id]
  tags            = module.label.tags
}
