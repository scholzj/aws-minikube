# AWS Minikube

AWS Minikube is a single node Kubernetes deployment in AWS. It creates an EC2 host and deploys the Kubernetes cluster using [Kubeadm](https://kubernetes.io/docs/admin/kubeadm/) tool. It provides full integration with AWS. It is also able to handle ELB load balancers, EBS disks, Route53 domains and other AWS resources.

<!-- TOC depthFrom:2 -->

- [Updates](#updates)
- [Prerequisites and Dependencies](#prerequisites-and-dependencies)
- [Configuration](#configuration)
- [Creating AWS Minikube](#creating-aws-minikube)
- [Deleting AWS Minikube](#deleting-aws-minikube)
- [Addons](#addons)
- [Custom Addons](#custom-addons)
- [Tagging](#tagging)
- [Frequently Asked Questions](#frequently-asked-questions)
    - [How to access Kuberntes Dashboard](#how-to-access-kuberntes-dashboard)

<!-- /TOC -->

## Updates

* **24.3.2018:** Update to Kubernetes 1.9.6
* **17.3.2018:** Update to Kubernetes 1.9.4
* **10.2.2018:** Update to Kubernetes 1.9.3
* **22.1.2018:** Update Calico to 3.0.1
* **22.1.2018:** Update to Kubernetes 1.9.2, Ingres 0.10.0 and Dashboard 1.8.2
* **6.1.2018:** Update to Kubernetes 1.9.1
* **16.12.2017:** Update to Kubernetes 1.9.0, update Dashboard, Ingress and Heapster dependencies
* **8.12.2017:** Update to Kubernetes 1.8.5
* **1.12.2017:** Fix problems with incorrect Ingress RBAC rights
* **28.11.2017:** Update addons (Heapster, Ingress, Dashboard, External DNS)
* **23.11.2017:** Update to Kubernetes 1.8.4
* **9.11.2017:** Update to Kubernetes 1.8.3
* **4.11.2017:** Update to Kubernetes 1.8.2
* **14.10.2017:** Update to Kubernetes 1.8.1
* **29.9.2017:** Update to Kubernetes 1.8
* **28.9.2017:** Updated addon versions
* **26.9.2017:** Split into module and configuration
* **23.9.2017:** Bootstrap cluster purely through cloud init to skip AWS S3
* **18.9.2017:** Clarify the requirements for AWS infrastructure
* **11.9.2017:** Make it possible to connect to the cluster through the Elastic IP address instead of DNS name
* **2.9.2017:** Update to Kubeadm and Kubernetes 1.7.5
* **22.8.2017:** Update to Kubeadm and Kubernetes 1.7.4

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
| `hosted_zone` | DNS zone which should be used | `my-domain.com` |
| `hosted_zone_private` | Is the DNS zone public or ptivate | `false` |
| `addons` | List of addons which should be installed | `[ "https://raw.githubusercontent.com/scholzj/aws-minikube/master/addons//storage-class.yaml" ]` |
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
* External DNS
* Ingress

The addons will be installed automatically based on the Terraform variables. 

## Custom Addons

Custom addons can be added if needed. Fro every URL in the `addons` list, the initialization scripts will automatically call `kubectl -f apply <Addon URL>` to deploy it. Minikube is using RBAC. So the custom addons have to be *RBAC ready*.

## Tagging

If you need to tag resources created by your Kubernetes cluster (EBS volumes, ELB load balancers etc.) check [this AWS Lambda function which can do the tagging](https://github.com/scholzj/aws-kubernetes-tagging-lambda).

## Frequently Asked Questions

### How to access Kuberntes Dashboard

The Kubernetes Dashboard addon is by default not exposed to the internet. This is intentional for security reasons (no authentication / authorization) and to save costs for Amazon AWS ELB load balancer.

You can access the dashboard easily fro any computer with installed and configured `kubectl`:
1) From command line start `kubectl proxy`
2) Go to your browser and open [http://127.0.0.1:8001/ui](http://127.0.0.1:8001/ui)
