#####
# Security Group
#####

data "aws_subnet" "minikube_subnet" {
  id = "${var.aws_subnet_id}"
}

resource "aws_security_group" "minikube" {
  vpc_id = "${data.aws_subnet.minikube_subnet.vpc_id}"
  name = "${var.cluster_name}"

  tags = "${merge(map("Name", var.cluster_name, "KubernetesCluster", var.cluster_name), var.tags)}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#####
# IAM role
#####

data "template_file" "policy_json" {
  template = "${file("${path.module}/template/policy.json.tpl")}"

  vars {}
}

resource "aws_iam_policy" "minikube_policy" {
  name        = "${var.cluster_name}"
  path        = "/"
  description = "Policy for role ${var.cluster_name}"
  policy      = "${data.template_file.policy_json.rendered}"
}

resource "aws_iam_role" "minikube_role" {
  name = "${var.cluster_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "minikube-attach" {
  name       = "minikube-attachment"
  roles      = ["${aws_iam_role.minikube_role.name}"]
  policy_arn = "${aws_iam_policy.minikube_policy.arn}"
}

resource "aws_iam_instance_profile" "minikube_profile" {
  name  = "${var.cluster_name}"
  role = "${aws_iam_role.minikube_role.name}"
}

##########
# Keypair
##########

resource "aws_key_pair" "minikube_keypair" {
  key_name = "${var.cluster_name}"
  public_key = "${file(var.ssh_public_key)}"
}

#####
# EC2 instance
#####

data "aws_ami_ids" "centos7" {
  owners = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_eip" "minikube" {
  vpc      = true
}

resource "aws_instance" "minikube" {
    # Instance type - any of the c4 should do for now
    instance_type = "${var.aws_instance_type}"

    ami = "${data.aws_ami_ids.centos7.ids[0]}"

    key_name = "${aws_key_pair.minikube_keypair.key_name}"

    subnet_id = "${var.aws_subnet_id}"

    associate_public_ip_address = false

    vpc_security_group_ids = [
        "${aws_security_group.minikube.id}"
    ]

    iam_instance_profile = "${aws_iam_instance_profile.minikube_profile.name}"

    user_data = <<EOF
#!/bin/bash
export KUBEADM_TOKEN=${data.template_file.kubeadm_token.rendered}
export DNS_NAME=${var.cluster_name}.${var.hosted_zone}
export ADDONS="${join(" ", var.addons)}"

curl 	https://s3.amazonaws.com/scholzj-kubernetes/minikube/init-aws-minikube.sh | bash
EOF

    tags = "${merge(map("Name", var.cluster_name, "KubernetesCluster", var.cluster_name), var.tags)}"

    root_block_device {
        volume_type = "gp2"
	      volume_size = "50"
	      delete_on_termination = true
    }

    depends_on = ["data.template_file.kubeadm_token"]
}

resource "aws_eip_association" "minikube_assoc" {
  instance_id   = "${aws_instance.minikube.id}"
  allocation_id = "${aws_eip.minikube.id}"
}

#####
# DNS record
#####

data "aws_route53_zone" "dns_zone" {
  name         = "${var.hosted_zone}."
  private_zone = "${var.hosted_zone_private}"
}

resource "aws_route53_record" "minikube" {
  zone_id = "${data.aws_route53_zone.dns_zone.zone_id}"
  name    = "${var.cluster_name}.${var.hosted_zone}"
  type    = "A"
  records = ["${aws_eip.minikube.public_ip}"]
  ttl     = 300
}

#####
# Output
#####

output "minikube_dns" {
    value = "${aws_route53_record.minikube.fqdn}"
}

output "copy_config" {
    value = "To copy the kubectl config file, run: 'scp centos@${aws_route53_record.minikube.fqdn}:/home/centos/kubeconfig .'"
}
