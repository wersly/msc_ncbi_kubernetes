# vpc
# ---
vpc_cidr = "10.1.0.0/16"
vpc_azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_public_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

# eks
# ---
# NOTE map_users defaults to my AWS account / the ARN of my identity on AWS
# if you wish to test/deploy this yourself and manage it via kubectl, you will need to supply your account/identity for eks_map_users and eks_map_accounts
eks_map_users = [
  {
    userarn = "arn:aws:iam::078654331827:user/warren"
    username = "warren"
    groups = ["system:masters"]
  },
  {
    userarn = "arn:aws:iam::078654331827:user/root"
    username = "root"
    groups = ["system:masters"]
  }
]

eks_map_accounts = ["078654331827"]
