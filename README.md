# AWS Minikube

AWS Minikube is a single node Kubernetes deployment in AWS. It creates an EC2 host and deploys the Kubernetes cluster using [Kubeadm](https://kubernetes.io/docs/admin/kubeadm/) tool. It provides full integration with AWS. It is also able to handle ELB load balancers, EBS disks, Route53 domains and other AWS resources.

**This project is intended for short-lived development and testing. Not for production use.**

<!-- TOC depthFrom:2 -->

- [Updates](#updates)
- [Prerequisites and Dependencies](#prerequisites-and-dependencies)
- [Configuration](#configuration)
- [Creating AWS Minikube](#creating-aws-minikube)
- [Deleting AWS Minikube](#deleting-aws-minikube)
- [Using custom AMI Image](#using-custom-ami-image)
- [Add-ons](#addons)
- [Custom Add-ons](#custom-addons)
- [Kubernetes version](#kubernetes-version)
- [Frequently Asked Questions](#frequently-asked-questions)
    - [How to access Kubernetes Dashboard](#how-to-access-kuberntes-dashboard)

<!-- /TOC -->

## Updates

* *14.9.2025* Update to Kube 1.34.1 and CRI-O 1.34.0
* *31.8.2025* Update to Kube 1.34.0
* *24.8.2025* Update to Kube 1.33.4 and CRI-O 1.33.3
* *18.6.2025* Update to Kube 1.33.2
* *5.6.2025* Update to Kube 1.33.1 and CRI-O 1.33.0
* *13.4.2025* Update to OpenTofu and rework the addons
* *7.4.2025* Update to Kube 1.32 and move from Calico to Flannel
* *26.3.2025* Update to use CentOS 10 and CRI-O
* *16.6.2024* Update to Kubernetes 1.30.2
* *19.5.2024* Update to Kubernetes 1.30.1 + Ingress and External DNS add-on updates
* *29.4.2024* Update to Kubernetes 1.30.0
* *31.3.2024* Update to Kubernetes 1.29.3 + Ingress and External DNS add-on updates
* *18.2.2024* Update to Kubernetes 1.29.2 + Ingress add-on update
* *30.12.2023* Update to Kubernetes 1.29.0
* *26.11.2023* Update to Kubernetes 1.28.4
* *12.11.2023* Update to Kubernetes 1.28.3 + Update some add-ons
* *15.10.2023* Update to Kubernetes 1.28.2 + Update some add-ons
* *16.4.2023* Update to Kubernetes 1.27.1 + Use external AWS Cloud Provider
* *1.4.2023* Update to Kubernetes 1.26.3 + update add-ons (Ingress-NGINX Controller, External DNS, Metrics Server, AWS EBS CSI Driver)
* *4.3.2023* Update to Kubernetes 1.26.2 + update add-ons (Ingress-NGINX Controller)
* *22.1.2023* Update to Kubernetes 1.26.1 + update add-ons (External DNS)
* *10.12.2022* Update to Kubernetes 1.26.0 + update add-ons (AWS EBS CSI Driver, Metrics server)
* *13.11.2022* Update to Kubernetes 1.25.4 + update add-ons
* *2.10.2022* Update to Kubernetes 1.25.2 + update add-ons
* *26.8.2022* Update to Kubernetes 1.25.0 + Calico upgrade

## Prerequisites and Dependencies

AWS Minikube deploys into an existing VPC / public subnet. If you don't have your VPC / subnet yet, you can use [this](https://github.com/scholzj/aws-vpc) configuration to create one.
  * The VPC / subnet should be properly linked with Internet Gateway (IGW) and should have DNS and DHCP enabled.
  * Hosted DNS zone configured in Route53 (in case the zone is private you have to use IP address to copy `kubeconfig` and access the cluster).

This project is now developed and tested using [OpenTofu](https://opentofu.org/) and that should be also the only local dependency you need to deploy AWS Minikube.
It should work also with [Terraform](https://www.terraform.io).
Kubeadm is used only on the EC2 host and doesn't have to be installed locally.

## Configuration

The configuration is done through Terraform variables. Example `tfvars` file is part of this repo and is named `example.tfvars`. Change the variables to match your environment / requirements before running `tofu apply ...`.

| Option | Explanation | Example |
|--------|-------------|---------|
| `aws_region` | AWS region which should be used | `eu-central-1` |
| `cluster_name` | Name of the Kubernetes cluster (also used to name different AWS resources) | `my-minikube` |
| `aws_instance_type` | AWS EC2 instance type | `t2.medium` |
| `ssh_public_key` | SSH key to connect to the remote machine | `~/.ssh/id_rsa.pub` |
| `aws_subnet_id` | Subnet ID where Minikube should run | `subnet-8d3407e5` |
| `ami_image_id` | ID of the AMI image which should be used. If empty, the latest CentOS 10 image will be used. See `README.md` for AMI image requirements. | `ami-099991f9035126091` |
| `hosted_zone` | DNS zone which should be used | `my-domain.com` |
| `hosted_zone_private` | Is the DNS zone public or private | `false` |
| `addons` | List of add-ons which should be installed | `[ "https://raw.githubusercontent.com/scholzj/aws-minikube/master/addons//storage-class.yaml" ]` |
| `tags` | Tags which should be applied to all resources | `{ Hello = "World" }` |
| `ssh_access_cidr` | Network CIDR from which SSH access will be allowed | `0.0.0.0/0` |
| `api_access_cidr` | Network CIDR from which API access will be allowed | `0.0.0.0/0` |

## Creating AWS Minikube

To create AWS Minikube, 
* Export AWS credentials into environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
* Apply OpenTofu configuration:
```bash
tofu apply --var-file example.tfvars
```

## Deleting AWS Minikube

To delete AWS Minikube, 
* Export AWS credentials into environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
* Destroy OpenTofu configuration:
```bash
tofu destroy --var-file example.tfvars
```

## Using custom AMI Image

AWS Minikube is built and tested on CentOS 10. But gives you the possibility to use their own AMI images. Your custom AMI image should be based on RPM distribution and should be similar to Cent OS 10. When `ami_image_id` variable is not specified, the latest available CentOS 10 image will be used.

## Add-ons

Currently, following add-ons are supported:
* Kubernetes Dashboard
* External DNS
* Kubernetes Nginx Ingress Controller
* Kubernetes Metrics Server

The add-ons will be installed automatically based on the Terraform variables. 

## Custom Add-ons

Custom add-ons can be added if needed.
From every URL in the `addons` list, the initialization scripts will automatically run it using `bash` to deploy it.
Minikube is using RBAC.
So the custom add-ons have to be *RBAC ready*.

## Kubernetes version

The intent for this module is to use it for development and testing against the latest version of Kubernetes. As such, the primary goal for this module is to ensure it works with whatever is the latest version of Kubernetes supported by Minikube. This includes provisioning the cluster as well as setting up networking and any of the [supported add-ons](#add-ons). This module might, but is not guaranteed to, also work with other versions of Kubernetes. At your own discretion, you can use the `kubernetes_version` variable to specify a different version of Kubernetes for the Minikube cluster.

## Frequently Asked Questions

### How to access Kubernetes Dashboard

The Kubernetes Dashboard add-on is by default not exposed to the internet. This is intentional for security reasons (no authentication / authorization) and to save costs for Amazon AWS ELB load balancer.

You can access the dashboard easily fro any computer with installed and configured `kubectl`:
1) From command line start `kubectl proxy`
2) Go to your browser and open [http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#/workloads?namespace=default](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#/workloads?namespace=default)
