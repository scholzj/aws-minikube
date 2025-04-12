# AWS region where should the Minikube be deployed
aws_region = "eu-central-1"

# Name for role, policy and cloud formation stack (without DBG-DEV- prefix)
cluster_name = "my-minikube"

# Instance type
aws_instance_type = "t2.medium"

# SSH key for the machine
ssh_public_key = "~/.ssh/id_rsa.pub"

# Subnet ID where the minikube should run
aws_subnet_id = "subnet-8a3517f8"

# DNS zone where the domain is placed
hosted_zone = "my-domain.com"
hosted_zone_private = false

# AMI image to use (if empty or not defined, latest CentOS 10 will be used)
#ami_image_id = "ami-099991f9035126091"

# Tags
tags = {
  Application = "Minikube"
}

# Supported addons:
# 
# https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/kubernetes-dashabord/init.sh
# https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/kubernetes-metrics-server/init.sh
# https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/external-dns/init.sh
# https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/kubernetes-nginx-ingress/init.sh

addons = [
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/kubernetes-dashabord/init.sh",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/kubernetes-metrics-server/init.sh",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/external-dns/init.sh",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/kubernetes-nginx-ingress/init.sh"
]
