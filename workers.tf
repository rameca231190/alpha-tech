locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${var.cluster-name} --apiserver-endpoint '${aws_eks_cluster.cluster_eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster_eks.certificate_authority[0].data}'
USERDATA
}

resource "aws_launch_configuration" "cluster-eks" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.node.name
  image_id                    = var.image_id
  instance_type               = "t3.medium"
  name_prefix                 = "terraform-eks-${var.env}"
  security_groups             = [aws_security_group.node.id]
  user_data_base64            = base64encode(local.node-userdata)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster_eks_as" {
  desired_capacity     = 3
  launch_configuration = aws_launch_configuration.cluster-eks.id
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = var.private_subnets

  tag {
    key                 = "Name"
    value               = "terraform-eks-${var.env}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_configuration.cluster-eks]
}
