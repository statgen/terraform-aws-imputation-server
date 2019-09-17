provider "aws" {
  region = "us-east-2"
}


module "imputation-server" {
  source = "../.."


}
