# AWS region where should the Minikube be deployed
aws_region    = "us-east-1"

# Name for role, policy and cloud formation stack (without DBG-DEV- prefix)
cluster_name  = "my-minikube"

# Instance type
aws_instance_type = "m4.2xlarge"

# SSH key for the machine
ssh_public_key = "~/.ssh/id_rsa.pub"

# Subnet ID where the minikube should run
aws_subnet_id = "subnet-4b217967"

# DNS zone where the domain is placed
hosted_zone = "j9z.cz"
hosted_zone_private = false

# Tags
tags = {
  Application = "Minikube"
}

# Kubernetes Addons
# Supported addons:
# 
# https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/storage-class.yaml
# https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/heapster.yaml
# https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/dashboard.yaml
# https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/external-dns.yaml
# https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/ingress.yaml (External ELB load balancer)

addons = [
  "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/storage-class.yaml",
  "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/dashboard.yaml",
  "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/external-dns.yaml",
  "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/metrics-server.yaml"
]