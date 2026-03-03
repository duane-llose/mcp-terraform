terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

provider "github" {
  owner = "duane-llose"
  token = var.token
}
