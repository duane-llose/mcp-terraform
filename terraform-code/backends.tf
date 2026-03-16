# terraform {
#   backend "local" {
#     path = "../state/terraform.tfstate"
#   }
# }

terraform { 
  cloud { 
    
    organization = "mtc-tf-duane-2026" 

    workspaces { 
      name = "dev" 
    } 
  } 
}