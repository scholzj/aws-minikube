# AWS Minikube

AWS Minikube is a single node Kubernetes deployment in AWS. It creates an EC2 host and deploys the Kubernetes cluster using [Kubeadm](https://kubernetes.io/docs/admin/kubeadm/) tool. It provides full integration with AWS. It is also able to handle ELB load balancers, EBS disks, Route53 domains and other AWS resources.

<!-- TOC depthFrom:2 -->

- [Updates](#updates)
- [Prerequisites and Dependencies](#prerequisites-and-dependencies)
- [Configuration](#configuration)
- [Creating AWS Minikube](#creating-aws-minikube)
- [Deleting AWS Minikube](#deleting-aws-minikube)
- [Using custom AMI Image](#using-custom-ami-image)
- [Addons](#addons)
- [Custom Addons](#custom-addons)
- [Tagging](#tagging)
- [Frequently Asked Questions](#frequently-asked-questions)
    - [How to access Kuberntes Dashboard](#how-to-access-kuberntes-dashboard)

<!-- /TOC -->

## Updates

* *12.4.2020* Update to Kubernetes 1.18.1
* *29.4.2020* Update to Kubernetes 1.18.0, update some addons
* *21.3.2020* Update to Kubernetes 1.17.4
* *3.3.2020* Update to Kubernetes 1.17.3, update addons and Calico SDN
* *15.12.2019* Update to Kubernetes 1.17.0
* *24.11.2019* Update to Kubernetes 1.16.3
* *20.10.2019* Update to Kubernetes 1.16.2
* *6.10.2019* Update to Kubernetes 1.16.1
* *21.9.2019* Update to Kubernetes 1.16, update addons and Calico
* *24.8.2019* Update to Kubernetes 1.15.3, fix Ingress RBAC
* *6.8.2019* Update to Kubernetes 1.15.2
* *27.7.2019* Update to Kubernetes 1.15.1, upgrade addons and move to Terraform 0.12
* *8.6.2019* Update to Kubernetes 1.14.3, better SE Linux handling, SSH and API CIDR configuration (thats for the contributions)
* *22.5.2019* Update to Kubernetes 1.14.2
* *13.4.2019* Update to Kubernetes 1.14.1
* *31.3.2019* Update to Kubernetes 1.14.0, Ingress 0.23.0, External DNS 0.5.12, Calico 3.6.1
* *2.3.2019* Update to Kubernetes 1.13.4 ([CVE-2019-1002100](https://github.com/kubernetes/kubernetes/issues/74534))
* *3.2.2019* Update to Kubernetes 1.13.3
* *19.1.2019* Update to Kubernetes 1.13.2
* *28.12.2018* Update Kubernetes Dashboard to 1.10.1
* *17.12.2018* Update to Kubernetes 1.13.1 and Calico 3.4.0
* *8.12.2018* Update to Kubernetes 1.13.0, added storage class for `st1` HDD disks and upgrade to Ingress 0.21.0
* *1.12.2018* Update to Kubernetes 1.12.3 and External DNS 0.5.9
* *9.11.2018* Update to Kubernetes 1.12.2, Update addons (Dashboard 1.10.0, Heapster 1.5.4, Ingress 0.20.0, External DNS 0.5.8)
* *18.8.2018* Update to Kubernetes 1.11.2, Update addons (Dashboard 1.8.3, Heapster 1.5.3, Ingress 0.17.1, External DNS 0.5.4)
* *28.6.2018:* Fix error when disabling already disabled SE Linux ([#1](https://github.com/scholzj/terraform-aws-minikube/pull/1))
* *23.6.2018:* Update to Kubernetes 1.10.5
* *8.6.2018:* Update to Kubernetes 1.10.4
* *27.5.2018:* Update to Kubernetes 1.10.3
* *28.4.2018:* Update to Kubernetes 1.10.2, make AMI image configurable
* *24.3.2018:* Update to Kubernetes 1.10.1
* *31.3.2018:* Update to Kubernetes 1.10.0, update Calico networking and update Kubernetes Dahsboard, Ingress and Heapster addons
* *24.3.2018:* Update to Kubernetes 1.9.6
* *17.3.2018:* Update to Kubernetes 1.9.4
* *10.2.2018:* Update to Kubernetes 1.9.3
* *22.1.2018:* Update Calico to 3.0.1
* *22.1.2018:* Update to Kubernetes 1.9.2, Ingres 0.10.0 and Dashboard 1.8.2
* *6.1.2018:* Update to Kubernetes 1.9.1
* *16.12.2017:* Update to Kubernetes 1.9.0, update Dashboard, Ingress and Heapster dependencies
* *8.12.2017:* Update to Kubernetes 1.8.5
* *1.12.2017:* Fix problems with incorrect Ingress RBAC rights
* *28.11.2017:* Update addons (Heapster, Ingress, Dashboard, External DNS)
* *23.11.2017:* Update to Kubernetes 1.8.4
* *9.11.2017:* Update to Kubernetes 1.8.3
* *4.11.2017:* Update to Kubernetes 1.8.2
* *14.10.2017:* Update to Kubernetes 1.8.1
* *29.9.2017:* Update to Kubernetes 1.8
* *28.9.2017:* Updated addon versions
* *26.9.2017:* Split into module and configuration
* *23.9.2017:* Bootstrap cluster purely through cloud init to skip AWS S3
* *18.9.2017:* Clarify the requirements for AWS infrastructure
* *11.9.2017:* Make it possible to connect to the cluster through the Elastic IP address instead of DNS name
* *2.9.2017:* Update to Kubeadm and Kubernetes 1.7.5
* *22.8.2017:* Update to Kubeadm and Kubernetes 1.7.4

## Prerequisites and Dependencies

AWS Minikube deployes into an existing VPC / public subnet. If you don't have your VPC / subnet yet, you can use [this](https://github.com/scholzj/aws-vpc) configuration to create one.
  * The VPC / subnet should be properly linked with Internet Gateway (IGW) and should have DNS and DHCP enabled.
  * Hosted DNS zone configured in Route53 (in case the zone is private you have to use IP address to copy `kubeconfig` and access the cluster).
To deploy AWS Minikube there are no other dependencies apart from [Terraform](https://www.terraform.io). Kubeadm is used only on the EC2 host and doesn't have to be installed locally.

## Configuration

The configuration is done through Terraform variables. Example *tfvars* file is part of this repo and is named `example.tfvars`. Change the variables to match your environment / requirements before running `terraform apply ...`.

| Option | Explanation | Example |
|--------|-------------|---------|
| `aws_region` | AWS region which should be used | `eu-central-1` |
| `cluster_name` | Name of the Kubernetes cluster (also used to name different AWS resources) | `my-minikube` |
| `aws_instance_type` | AWS EC2 instance type | `t2.medium` |
| `ssh_public_key` | SSH key to connect to the remote machine | `~/.ssh/id_rsa.pub` |
| `aws_subnet_id` | Subnet ID where minikube should run | `subnet-8d3407e5` |
| `ami_image_id` | ID of the AMI image which should be used. If empty, the latest CentOS 7 image will be used. See README.md for AMI image requirements. | `ami-b81dbfc5` |
| `hosted_zone` | DNS zone which should be used | `my-domain.com` |
| `hosted_zone_private` | Is the DNS zone public or ptivate | `false` |
| `addons` | List of addons which should be installed | `[ "https://raw.githubusercontent.com/scholzj/aws-minikube/master/addons//storage-class.yaml" ]` |
| `tags` | Tags which should be applied to all resources | `{ Hello = "World" }` |
| `ssh_access_cidr` | Network CIDR from which SSH access will be allowed | `0.0.0.0/0` |
| `api_access_cidr` | Network CIDR from which API access will be allowed | `0.0.0.0/0` |

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

## Using custom AMI Image

AWS Minikube is built and tested on CentOS 7. But gives you the possibility to use their own AMI images. Your custom AMI image should be based on RPM distribution and should be similar to Cent OS 7. When `ami_image_id` variable is not specified, the latest available CentOS 7 image will be used.

## Addons

Currently, following addons are supported:
* Kubernetes dashboard
* Heapster for resource monitoring
* Storage class for automatic provisioning of persisitent volumes
* External DNS
* Ingress

The addons will be installed automatically based on the Terraform variables. 

## Custom Addons

Custom addons can be added if needed. From every URL in the `addons` list, the initialization scripts will automatically call `kubectl -f apply <Addon URL>` to deploy it. Minikube is using RBAC. So the custom addons have to be *RBAC ready*.

## Tagging

If you need to tag resources created by your Kubernetes cluster (EBS volumes, ELB load balancers etc.) check [this AWS Lambda function which can do the tagging](https://github.com/scholzj/aws-kubernetes-tagging-lambda).

## Frequently Asked Questions

### How to access Kuberntes Dashboard

The Kubernetes Dashboard addon is by default not exposed to the internet. This is intentional for security reasons (no authentication / authorization) and to save costs for Amazon AWS ELB load balancer.

You can access the dashboard easily fro any computer with installed and configured `kubectl`:
1) From command line start `kubectl proxy`
2) Go to your browser and open [http://127.0.0.1:8001/ui](http://127.0.0.1:8001/ui)
