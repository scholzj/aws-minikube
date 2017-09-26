module "minikube" {
  source = "github.com/scholzj/terraform-aws-minikube"

  aws_region          = "${var.aws_region}"
  cluster_name        = "${var.cluster_name}"
  aws_instance_type   = "${var.aws_instance_type}"
  ssh_public_key      = "${var.ssh_public_key}"
  aws_subnet_id       = "${var.aws_subnet_id}"
  hosted_zone         = "${var.hosted_zone}"
  hosted_zone_private = "${var.hosted_zone_private}"
  tags = "${var.tags}"
  addons = "${var.addons}"
}