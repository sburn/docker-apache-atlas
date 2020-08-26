region = "eu-west-1"

availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

namespace = "wolt"

stage = "dev"

name = "emr"

ebs_root_volume_size = 10

visible_to_all_users = true

release_label = "emr-5.30.1"

applications = ["HBase"]

core_instance_group_instance_type = "m5.xlarge"

core_instance_group_instance_count = 3

core_instance_group_ebs_size = 50

core_instance_group_ebs_type = "gp2"

core_instance_group_ebs_volumes_per_instance = 1

core_instance_group_bid_price = 0.09

master_instance_group_instance_type = "m5.xlarge"

master_instance_group_instance_count = 1

master_instance_group_ebs_size = 20

master_instance_group_ebs_type = "gp2"

master_instance_group_ebs_volumes_per_instance = 1

create_task_instance_group = false

ssh_public_key_path = "./"

generate_ssh_key = false