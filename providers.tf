terraform {
  required_providers {
    agyn = {
      source  = "agynio/agyn"
      version = "~> 0.6.8"
    }
  }
}

provider "agyn" {
  api_url   = var.api_url
  api_token = var.api_token
}
