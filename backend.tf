terraform {
  # Bucket and region are fixed for this repo. Only `key` is supplied at
  # `terraform init` time, namespaced by repo and environment:
  #   -backend-config="key=fdp-infra-database/<env>/terraform.tfstate"
  #
  # Native S3 state locking (Terraform >= 1.10) - no DynamoDB lock table.
  backend "s3" {
    bucket       = "REPLACE-org-infra-state-bucket-ACCTID-eu-west-2-suffix"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
}
