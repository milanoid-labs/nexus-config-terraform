# Hosted Docker/OCI registry for homelab images, first of all the KubeVirt runner VM
# containerDisk. Path-based routing (Nexus >= 3.83) serves it on the main 8081 port as
#   192.168.1.204:8081/docker-hosted/<image>:<tag>
# so no extra connector port or docker-compose change is needed.
# Read at plan time, so a missing blob store fails the PR plan instead of the apply on main.
data "nexus_blobstore_file" "default" {
  name = "default"
}

resource "nexus_repository_docker_hosted" "docker_hosted" {
  name   = "docker-hosted"
  online = true

  docker {
    # Basic auth only: no Docker Bearer Token Realm needed, and anonymous pulls stay off.
    force_basic_auth   = true
    v1_enabled         = false
    path_based_routing = true
  }

  storage {
    blob_store_name                = data.nexus_blobstore_file.default.name
    strict_content_type_validation = true
    # Tags are immutable once pushed: images are referenced by date tag + digest, and a
    # re-pushed tag would silently change what a pinned tag means.
    write_policy = "ALLOW_ONCE"
  }
}
