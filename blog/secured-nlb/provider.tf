provider "aws" {
  region  = "us-east-1"
  profile = var.profile
  version = "~> 2.42"
}

provider "random" {
  version = "~> 2.2"
}


