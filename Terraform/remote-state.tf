terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "shinra"

    workspaces {
      name = "shinra"
    }
  }
}