provider "aws" {
  region = "us-east-2"
}


module "imputation-server" {
  source = "../.."

  name_prefix = "csg-imputation"
  public_key  = ""
}
