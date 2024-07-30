

variable "project_id" {
  description = "The project ID to deploy to"
}

variable "region" {
  description = "The region to deploy to"
}

variable "network_name" {
  description = "The name of the network"
}

variable "gke_node_network_tags" {
  description = "The network tags for GKE nodes"
}

variable "neg_name" {
  description = "The name of the network endpoint group"
}

variable "neg_zone" {
  description = "The zone of the network endpoint group"
}

variable "neg_instance_count" {
  description = "The number of instances in the network endpoint group"
  default     = 1
}

variable "neg_instance_names" {
  description = "The names of the instances in the network endpoint group"
  type        = list(string)
  default     = ["your-instance-name-1", "your-instance-name-2"] # Replace with actual instance names
}

variable "neg_instance_ips" {
  description = "The IPs of the instances in the network endpoint group"
  type        = list(string)
  default     = ["your-instance-ip-1", "your-instance-ip-2"] # Replace with actual instance IPs
}
