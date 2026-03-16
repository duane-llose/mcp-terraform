resource "local_file" "repos" {
  content  = jsonencode(local.repos)
  filename = "${path.module}/repos.json"
}

module "repos" {
  source   = "./modules/dev-repos"
  repo_max = 9
  #   env      = "dev"
  for_each = var.environments
  env      = each.key
  # repos            = local.repos
  # repos = jsondecode(file("repos.json"))
  repos            = { for v in csvdecode(file("repos.csv")) : v["environment"] => v }
  run_provisioners = false
}



module "deploy_keys" {
  source    = "./modules/deploy-key"
  for_each  = var.deploy_key ? toset(flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"])) : []
  repo_name = each.key
}

# module "info_page" {
#   source           = "./modules/info-page"
#   repos            = { for k, v in module.repos["prod"].clone-urls : k => v }
#   run_provisioners = false
# }

output "repo-info" {
  value = { for k, v in module.repos : k => v.clone-urls }
}

output "repo-list" {
  value = flatten([for k, v in module.repos : keys(v.clone-urls) if k == "dev"])
}

output "clone_urls" {
  value = module.repos
}
