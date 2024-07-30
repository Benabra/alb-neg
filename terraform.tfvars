# terraform.tfvars

project_id            = "test-jihad"
region                = "europe-west1"
network_name          = "tooling-test"
gke_node_network_tags = ["tooling"]
neg_name              = "tooling-lb-neg"
neg_zone              = "europe-west1-d"
neg_instance_count    = 2
neg_instance_names    = ["your-instance-name-1", "your-instance-name-2"]
neg_instance_ips      = ["your-instance-ip-1", "your-instance-ip-2"]
