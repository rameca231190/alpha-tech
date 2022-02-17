# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.cluster_eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster_eks.certificate_authority[0].data}' '${var.cluster-name}'
USERDATA

}

resource "aws_launch_configuration" "cluster_eks" {
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.node.name
  image_id = var.image_id
  instance_type = "t3.medium"
  name_prefix = "terraform-eks-${var.env}"
  security_groups = [aws_security_group.node.id]
  user_data_base64 = base64encode(local.node-userdata)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster_eks" {
  desired_capacity = 2
  launch_configuration = aws_launch_configuration.cluster_eks.id
  max_size = 2
  min_size = 1
  name = "terraform-eks-${var.env}"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  vpc_zone_identifier = var.public_subnets

  tag {
    key = "Name"
    value = "terraform-eks-${var.env}"
    propagate_at_launch = true
  }

  tag {
    key = "kubernetes.io/cluster/${var.cluster-name}"
    value = "owned"
    propagate_at_launch = true
  }
}

