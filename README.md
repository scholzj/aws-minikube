# AWS Minikube

AWS Minikube is a single node Kubernetes deployment in AWS. It creates EC2 host and deploys Kubernetes cluster using [Kubeadm](https://kubernetes.io/docs/admin/kubeadm/) tool. Minikube provides full integration with AWS. It is able to handle ELB load balancers, EBS disks, Route53 domains etc.

<!-- TOC -->

- [AWS Minikube](#aws-minikube)
    - [Prerequisites and dependencies](#prerequisites-and-dependencies)
    - [Configuration](#configuration)
    - [Creating AWS Minikube](#creating-aws-minikube)
    - [Deleting AWS Minikube](#deleting-aws-minikube)
    - [Addons](#addons)
    - [Custom addons](#custom-addons)

<!-- /TOC -->

## Prerequisites and dependencies

* AWS Minikube deployes into existing VPC / public subnet. If you don't have your VPC / subnet yet, you can use [this](https://github.com/scholzj/aws-vpc) configuration to create one.
* To deploy AWS Minikube there are no other dependencies apart from [Terraform](https://www.terraform.io). Kubeadm is used only on the EC2 host and doesn't have to be installed locally.

## Configuration

The configuration is done through Terraform variables. Example *tfvars* file is part of this repo and is named `example.tfvars`. Change the variables to match your environment / requirements before running `terraform apply ...`.

| Option | Explanation | Example |
|--------|-------------|---------|
| `aws_region` | AWS region which should be used | `eu-central-1` |
| `cluster_name` | Name of the Kubernetes cluster (also used to name different AWS resources) | `my-minikube` |
| `aws_instance_type` | AWS EC2 instance type | `t2.medium` |
| `ssh_public_key` | SSH key to connect to the remote machine | `~/.ssh/id_rsa.pub` |
| `aws_subnet_id` | Subnet ID where minikube should run | `subnet-8d3407e5` |
| `hosted_zone` | DNS zone which should be used | `my-domain.com` |
| `hosted_zone_private` | Is the DNS zone public or ptivate | `false` |
| `addons` | List of addons which should be installed | `[ "https://s3.amazonaws.com/scholzj-kubernetes/minikube/addons/storage-class.yaml" ]` |
| `tags` | Tags which should be applied to all resources | `{ Hello = "World" }` |

## Creating AWS Minikube

To create AWS Minikube, 
* Export AWS credentials into environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
* Apply Terraform configuration:
```bash
terraform apply --var-file example.tfvars
```

## Deleting AWS Minikube

To delete AWS Minikube, 
* Export AWS credentials into environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
* Destroy Terraform configuration:
```bash
terraform destroy --var-file example.tfvars
```

## Addons

Currently, following addons are supported:
* Kubernetes dashboard
* Heapster for resource monitoring
* Storage class for automatic provisioning of persisitent volumes
* Route53 Mapper (Obsolete - Replaced by External DNS)
* External DNS (Replaces Route53 mapper)
* Ingress

The addons will be installed automatically based on the Terraform variables. 

## Custom addons

Custom addons can be added if needed. Fro every URL in the `addons` list, the initialization scripts will automatically call `kubectl -f apply <Addon URL>` to deploy it. Minikube is using RBAC. So the custom addons have to be *RBAC ready*.
