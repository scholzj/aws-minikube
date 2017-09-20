# AWS region where should the Minikube be deployed
aws_region    = "eu-central-1"

# Name for role, policy and cloud formation stack (without DBG-DEV- prefix)
cluster_name  = "my-minikube"

# Instance type
aws_instance_type = "t2.medium"

# SSH key for the machine
ssh_public_key = "~/.ssh/id_rsa.pub"

# Subnet ID where the minikube should run
aws_subnet_id = "subnet-8a3517f8"

# DNS zone where the domain is placed
hosted_zone = "my-domain.com"
hosted_zone_private = false

# Tags
tags = {
  Application = "Minikube"
}

# Kubernetes Addons
# Supported addons:
# storage-class.yaml
# heapster.yaml
# dashboard.yaml
# route53-mapper.yaml
# external-dns.yaml
# ingress.yaml"
# ingress-internal.yaml"

addons = [
  "storage-class.yaml",
  "heapster.yaml",
  "dashboard.yaml",
  "external-dns.yaml"
]
