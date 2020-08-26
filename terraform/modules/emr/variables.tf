variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources"
  default     = true
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
  default     = ""
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  default     = ""
}

variable "name" {
  type        = string
  description = "Name of the application"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  description = "Additional attributes (_e.g._ \"1\")"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (_e.g._ { BusinessUnit : ABC })"
  default     = {}
}

variable "zone_id" {
  type        = string
  description = "Route53 parent zone ID. If provided (not empty), the module will create sub-domain DNS records for the masters and slaves"
  default     = null
}

variable "master_allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of security groups to be allowed to connect to the master instances"
}

variable "slave_allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of security groups to be allowed to connect to the slave instances"
}

variable "master_allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to access the master instances"
}

variable "slave_allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to access the slave instances"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the cluster in (e.g. `vpc-a22222ee`)"
}

variable "master_dns_name" {
  type        = string
  description = "Name of the cluster CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `emr-master-var.name`"
  default     = null
}

variable "termination_protection" {
  type        = bool
  description = "Switch on/off termination protection (default is false, except when using multiple master nodes). Before attempting to destroy the resource when termination protection is enabled, this configuration must be applied with its value set to false"
  default     = false
}

variable "keep_job_flow_alive_when_no_steps" {
  type        = bool
  description = "Switch on/off run cluster with no steps or when all steps are complete"
  default     = true
}

variable "ebs_root_volume_size" {
  type        = number
  description = "Size in GiB of the EBS root device volume of the Linux AMI that is used for each EC2 instance. Available in Amazon EMR version 4.x and later"
  default     = 10
}

variable "custom_ami_id" {
  type        = string
  description = "A custom Amazon Linux AMI for the cluster (instead of an EMR-owned AMI). Available in Amazon EMR version 5.7.0 and later"
  default     = null
}

variable "visible_to_all_users" {
  type        = bool
  description = "Whether the job flow is visible to all IAM users of the AWS account associated with the job flow"
  default     = true
}

variable "release_label" {
  type        = string
  description = "The release label for the Amazon EMR release. https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-release-5x.html"
  default     = "emr-5.25.0"
}

variable "applications" {
  type        = list(string)
  description = "A list of applications for the cluster. Valid values are: Flink, Ganglia, Hadoop, HBase, HCatalog, Hive, Hue, JupyterHub, Livy, Mahout, MXNet, Oozie, Phoenix, Pig, Presto, Spark, Sqoop, TensorFlow, Tez, Zeppelin, and ZooKeeper (as of EMR 5.25.0). Case insensitive"
}

# https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-configure-apps.html
variable "configurations_json" {
  type        = string
  description = "A JSON string for supplying list of configurations for the EMR cluster. See https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-configure-apps.html for more details"
  default     = ""
}

variable "key_name" {
  type        = string
  description = "Amazon EC2 key pair that can be used to ssh to the master node as the user called `hadoop`"
  default     = null
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "subnet_id" {
  type        = string
  description = "VPC subnet ID where you want the job flow to launch. Cannot specify the `cc1.4xlarge` instance type for nodes of a job flow launched in a Amazon VPC"
}

variable "subnet_type" {
  type        = string
  description = "Type of VPC subnet ID where you want the job flow to launch. Supported values are `private` or `public`"
  default     = "private"
}

variable "route_table_id" {
  type        = string
  description = "Route table ID for the VPC S3 Endpoint when launching the EMR cluster in a private subnet. Required when `subnet_type` is `private`"
  default     = ""
}

variable "log_uri" {
  type        = string
  description = "The path to the Amazon S3 location where logs for this cluster are stored"
  default     = null
}

variable "core_instance_group_instance_type" {
  type        = string
  description = "EC2 instance type for all instances in the Core instance group"
}

variable "core_instance_group_instance_count" {
  type        = number
  description = "Target number of instances for the Core instance group. Must be at least 1"
  default     = 1
}

variable "core_instance_group_ebs_size" {
  type        = number
  description = "Core instances volume size, in gibibytes (GiB)"
}

variable "core_instance_group_ebs_type" {
  type        = string
  description = "Core instances volume type. Valid options are `gp2`, `io1`, `standard` and `st1`"
  default     = "gp2"
}

variable "core_instance_group_ebs_iops" {
  type        = number
  description = "The number of I/O operations per second (IOPS) that the Core volume supports"
  default     = null
}

variable "core_instance_group_ebs_volumes_per_instance" {
  type        = number
  description = "The number of EBS volumes with this configuration to attach to each EC2 instance in the Core instance group"
  default     = 1
}

variable "core_instance_group_bid_price" {
  type        = string
  description = "Bid price for each EC2 instance in the Core instance group, expressed in USD. By setting this attribute, the instance group is being declared as a Spot Instance, and will implicitly create a Spot request. Leave this blank to use On-Demand Instances"
  default     = null
}

variable "core_instance_group_autoscaling_policy" {
  type        = string
  description = "String containing the EMR Auto Scaling Policy JSON for the Core instance group"
  default     = null
}

variable "master_instance_group_instance_type" {
  type        = string
  description = "EC2 instance type for all instances in the Master instance group"
}

variable "master_instance_group_instance_count" {
  type        = number
  description = "Target number of instances for the Master instance group. Must be at least 1"
  default     = 1
}

variable "master_instance_group_ebs_size" {
  type        = number
  description = "Master instances volume size, in gibibytes (GiB)"
}

variable "master_instance_group_ebs_type" {
  type        = string
  description = "Master instances volume type. Valid options are `gp2`, `io1`, `standard` and `st1`"
  default     = "gp2"
}

variable "master_instance_group_ebs_iops" {
  type        = number
  description = "The number of I/O operations per second (IOPS) that the Master volume supports"
  default     = null
}

variable "master_instance_group_ebs_volumes_per_instance" {
  type        = number
  description = "The number of EBS volumes with this configuration to attach to each EC2 instance in the Master instance group"
  default     = 1
}

variable "master_instance_group_bid_price" {
  type        = string
  description = "Bid price for each EC2 instance in the Master instance group, expressed in USD. By setting this attribute, the instance group is being declared as a Spot Instance, and will implicitly create a Spot request. Leave this blank to use On-Demand Instances"
  default     = null
}

variable "scale_down_behavior" {
  type        = string
  description = "The way that individual Amazon EC2 instances terminate when an automatic scale-in activity occurs or an instance group is resized"
  default     = null
}

variable "additional_info" {
  type        = string
  description = "A JSON string for selecting additional features such as adding proxy information. Note: Currently there is no API to retrieve the value of this argument after EMR cluster creation from provider, therefore Terraform cannot detect drift from the actual EMR cluster if its value is changed outside Terraform"
  default     = null
}

variable "security_configuration" {
  type        = string
  description = "The security configuration name to attach to the EMR cluster. Only valid for EMR clusters with `release_label` 4.8.0 or greater. See https://www.terraform.io/docs/providers/aws/r/emr_security_configuration.html for more info"
  default     = null
}

variable "create_task_instance_group" {
  type        = bool
  description = "Whether to create an instance group for Task nodes. For more info: https://www.terraform.io/docs/providers/aws/r/emr_instance_group.html, https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html"
  default     = false
}

variable "task_instance_group_instance_type" {
  type        = string
  description = "EC2 instance type for all instances in the Task instance group"
  default     = null
}

variable "task_instance_group_instance_count" {
  type        = number
  description = "Target number of instances for the Task instance group. Must be at least 1"
  default     = 1
}

variable "task_instance_group_ebs_size" {
  type        = number
  description = "Task instances volume size, in gibibytes (GiB)"
  default     = 10
}

variable "task_instance_group_ebs_optimized" {
  type        = bool
  description = "Indicates whether an Amazon EBS volume in the Task instance group is EBS-optimized. Changing this forces a new resource to be created"
  default     = false
}

variable "task_instance_group_ebs_type" {
  type        = string
  description = "Task instances volume type. Valid options are `gp2`, `io1`, `standard` and `st1`"
  default     = "gp2"
}

variable "task_instance_group_ebs_iops" {
  type        = number
  description = "The number of I/O operations per second (IOPS) that the Task volume supports"
  default     = null
}

variable "task_instance_group_ebs_volumes_per_instance" {
  type        = number
  description = "The number of EBS volumes with this configuration to attach to each EC2 instance in the Task instance group"
  default     = 1
}

variable "task_instance_group_bid_price" {
  type        = string
  description = "Bid price for each EC2 instance in the Task instance group, expressed in USD. By setting this attribute, the instance group is being declared as a Spot Instance, and will implicitly create a Spot request. Leave this blank to use On-Demand Instances"
  default     = null
}

variable "task_instance_group_autoscaling_policy" {
  type        = string
  description = "String containing the EMR Auto Scaling Policy JSON for the Task instance group"
  default     = null
}

variable "bootstrap_action" {
  type = list(object({
    path = string
    name = string
    args = list(string)
  }))
  description = "List of bootstrap actions that will be run before Hadoop is started on the cluster nodes"
  default     = []
}

variable "create_vpc_endpoint_s3" {
  type        = bool
  description = "Set to false to prevent the module from creating VPC S3 Endpoint"
  default     = true
}

variable "kerberos_enabled" {
  type        = bool
  description = "Set to true if EMR cluster will use kerberos_attributes"
  default     = false
}

variable "kerberos_ad_domain_join_password" {
  type        = string
  description = "The Active Directory password for ad_domain_join_user. Terraform cannot perform drift detection of this configuration."
  default     = null
}

variable "kerberos_ad_domain_join_user" {
  type        = string
  description = "Required only when establishing a cross-realm trust with an Active Directory domain. A user with sufficient privileges to join resources to the domain. Terraform cannot perform drift detection of this configuration."
  default     = null
}

variable "kerberos_cross_realm_trust_principal_password" {
  type        = string
  description = "Required only when establishing a cross-realm trust with a KDC in a different realm. The cross-realm principal password, which must be identical across realms. Terraform cannot perform drift detection of this configuration."
  default     = null
}

variable "kerberos_kdc_admin_password" {
  type        = string
  description = "The password used within the cluster for the kadmin service on the cluster-dedicated KDC, which maintains Kerberos principals, password policies, and keytabs for the cluster. Terraform cannot perform drift detection of this configuration."
  default     = null
}

variable "kerberos_realm" {
  type        = string
  description = "The name of the Kerberos realm to which all nodes in a cluster belong. For example, EC2.INTERNAL"
  default     = "EC2.INTERNAL"
}