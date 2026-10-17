# Push/pull access to docker-hosted. Nexus creates per-repository privileges named
# nx-repository-view-<format>-<repo>-<action> automatically for every repository.
locals {
  docker_hosted_privilege = "nx-repository-view-docker-${nexus_repository_docker_hosted.docker_hosted.name}"
}

resource "nexus_security_role" "docker_hosted_pull" {
  roleid      = "docker-hosted-pull"
  name        = "docker-hosted-pull"
  description = "Pull images from docker-hosted"
  privileges = [
    "${local.docker_hosted_privilege}-browse",
    "${local.docker_hosted_privilege}-read",
  ]
}

resource "nexus_security_role" "docker_hosted_push" {
  roleid      = "docker-hosted-push"
  name        = "docker-hosted-push"
  description = "Push and pull images in docker-hosted"
  privileges = [
    "${local.docker_hosted_privilege}-browse",
    "${local.docker_hosted_privilege}-read",
    "${local.docker_hosted_privilege}-add",
    "${local.docker_hosted_privilege}-edit",
  ]
}

# Service users. Passwords are generated here and live only in the (encrypted,
# repo-scoped) state; read them with `tofu output -raw <name>_password` to hand them
# to their consumer. Rotate with `tofu apply -replace=random_password.<name>`.
resource "random_password" "ci_push" {
  length  = 32
  special = false
}

resource "random_password" "k8s_pull" {
  length  = 32
  special = false
}

# Used by the kubevirt-scaleset repo's CI to push the runner VM image.
resource "nexus_security_user" "ci_push" {
  userid    = "ci-push"
  firstname = "CI"
  lastname  = "image push"
  email     = "ci-push@nexus.local"
  password  = random_password.ci_push.result
  roles     = [nexus_security_role.docker_hosted_push.roleid]
  status    = "active"
}

# Used by containerd on kubevirt01 (/etc/rancher/k3s/registries.yaml) to pull it.
resource "nexus_security_user" "k8s_pull" {
  userid    = "k8s-pull"
  firstname = "k3s"
  lastname  = "kubevirt01 pull"
  email     = "k8s-pull@nexus.local"
  password  = random_password.k8s_pull.result
  roles     = [nexus_security_role.docker_hosted_pull.roleid]
  status    = "active"
}

output "ci_push_password" {
  description = "Password of the ci-push Nexus user."
  value       = random_password.ci_push.result
  sensitive   = true
}

output "k8s_pull_password" {
  description = "Password of the k8s-pull Nexus user."
  value       = random_password.k8s_pull.result
  sensitive   = true
}
