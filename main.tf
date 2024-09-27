module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "5.13.0"
  name            = "ntier"
  cidr            = "10.0.0.0/16"
  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  tags = {
    Environment = "dev"
  }
}
module "web_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.2.0"
  name        = "web-sg"
  description = "security group for web (public subnets)"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [{
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "ssh"
    cidr_blocks = "0.0.0.0/0"
    }, {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "http"
    cidr_blocks = "0.0.0.0/0"
    }
  ]
  depends_on = [module.vpc]
}
module "db_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.2.0"
  name        = "db-sg"
  description = "security group for db (public subnets)"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [{
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "ssh"
    cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
  depends_on = [module.vpc]
}

module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  name                   = "single-instance"
  instance_type          = "t2.micro"
  key_name               = "mannu"
  monitoring             = true
  vpc_security_group_ids = [module.web_security_group.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  ami                    = "ami-0522ab6e1ddcc7055"
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


