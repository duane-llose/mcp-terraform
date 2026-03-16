resource "github_repository" "mtc_repo" {
  for_each    = var.repos
  name        = "mtc-${each.key}-${var.env}"
  description = "${each.value.lang} Code for MTC"
  visibility  = "public"
  # visibility  = var.env == "dev" ? "private" : "public"
  auto_init = true

  dynamic "pages" {
    for_each = each.value.pages ? [1] : []
    content {
      source {
        branch = "main"
        path   = "/"
      }
    }
  }

  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo view ${self.name} --web" : "echo 'skip repo view'"
  }
  provisioner "local-exec" {
    command = "rm -rf ${self.name}"
    when    = destroy
  }
}

resource "terraform_data" "repo-clone" {
  depends_on = [github_repository_file.readme, github_repository_file.main]
  for_each   = var.repos
  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo clone ${github_repository.mtc_repo[each.key].name}" : "echo 'skip clone'"
  }
}

resource "github_repository_file" "readme" {
  for_each   = var.repos
  repository = github_repository.mtc_repo[each.key].name
  branch     = "main"
  file       = "README.md"
  content = templatefile("${path.module}/templates/readme.tftpl", {
    lang = each.value.lang,
    name = data.github_user.current.name,
    repo = each.key,
    env  = var.env
  })
  overwrite_on_create = true

}

resource "github_repository_file" "main" {
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

moved {
  from = github_repository_file.repos
  to   = github_repository_file.main
}
