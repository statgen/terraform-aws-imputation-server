# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}


# ---------------------------------------------------------------------------------------------------------------------
# Create key pair
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "${var.name_prefix}-bastion"
  public_key = var.public_key
}

# ---------------------------------------------------------------------------------------------------------------------
# Create EC2 bastion instance(s) and encrypted AMI
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "this" {
  vpc      = true
  instance = module.bastion_host.id[0]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

resource "aws_ami_copy" "ubuntu-bionic-encrypted-ami" {
  name              = "bastion-host-ubuntu-bionic-encrypted-ami"
  description       = "An encrypted root ami based off ${data.aws_ami.ubuntu-bionic.id}"
  source_ami_id     = data.aws_ami.ubuntu-bionic.id
  source_ami_region = "us-east-2"
  encrypted         = true

  tags = {
    Name = "bastion-host-ubuntu-bionic-encrypted-ami"
  }
}

data "aws_ami" "ubuntu-bionic" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

module "bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.6.0"

  instance_count = 1

  name          = "${var.name_prefix}-bastion-host"
  ami           = aws_ami_copy.ubuntu-bionic-encrypted-ami.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.bastion_key_pair.key_name

  vpc_security_group_ids = [var.bastion_host_security_group_id]

  subnet_ids = var.bastion_host_subnet_ids

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = var.root_volume_size
    },
  ]

  tags = {
    Terraform   = "true"
    Environmnet = var.environment
  }
}
