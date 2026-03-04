resource "github_repository" "mtc_repo" {
  for_each    = var.repos
  name        = "mtc-repo-${each.key}"
  description = "${each.value.lang} Code for MTC"
  visibility  = var.env == "dev" ? "private" : "public"
  auto_init   = true
  provisioner "local-exec" {
    command = "gh repo view ${self.name} --web"
  }
  provisioner "local-exec" {
    command = "rm -rf ${self.name}"
    when    = destroy

  }
}

resource "terraform_data" "repo-clone" {
  depends_on = [github_repository_file.readme, github_repository_file.repos]
  for_each   = var.repos
  provisioner "local-exec" {
    command = "gh repo clone ${github_repository.mtc_repo[each.key].name}"
  }
}

resource "github_repository_file" "readme" {
  for_each   = var.repos
  repository = github_repository.mtc_repo[each.key].name
  branch     = "main"
  file       = "README.md"
  content = templatefile("templates/readme.tftpl", {
    lang = each.value.lang,
    name = data.github_user.current.name,
    repo = each.key,
    env  = var.env
  })
  overwrite_on_create = true
}

resource "github_repository_file" "repos" {
  for_each            = var.repos
  repository          = github_repository.mtc_repo[each.key].name
  branch              = "main"
  file                = each.value.filename
  content             = "#Hello ${each.value.lang}"
  overwrite_on_create = true
  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

data "github_user" "current" {
  username = ""
}

output "repo-names" {
  value       = { for i in github_repository.mtc_repo : i.name => [i.ssh_clone_url, i.http_clone_url] }
  description = "Repository Names and URL"
  sensitive   = false
}

# output "current_github_login" {
#   value = data.github_user.current.name
# }
