resource "github_repository" "this" {
  name        = "mtc-info-page"
  description = "Repo for MTC"
  visibility  = "public"
  auto_init   = true
  pages {
    source {
      branch = "main"
      path   = "/"
    }
  }
  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo view ${self.name} --web" : "echo 'skip repo view'"
  }
}

resource "time_static" "this" {

}

resource "github_repository_file" "this" {
  repository          = github_repository.this.name
  branch              = "main"
  file                = "README.md"
  overwrite_on_create = true
  content = templatefile("${path.module}/templates/index.tftpl", {
    name   = data.github_user.current.name,
    avatar = data.github_user.current.avatar_url,
    date   = time_static.this.year
    repos  = var.repos
  })
}

