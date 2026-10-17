# Active security realms, in order. This resource owns the WHOLE list (and may exist only
# once per Nexus): a realm missing here is switched off on apply. Before adding or removing
# one, compare with Settings → Security → Realms.
#
# DockerToken (Docker Bearer Token Realm): with path-based routing, Docker/Podman clients
# first hit the Nexus-wide /v2/, which always answers with a Bearer challenge. Nexus issues
# the token either way, but without this realm it can't validate it, so the follow-up
# request runs as anonymous and is refused (seen as 429 in request.log, user "-").
# force_basic_auth on the repository only covers requests inside the repository path.
resource "nexus_security_realms" "this" {
  active = [
    "NexusAuthenticatingRealm", # Local Authenticating Realm: Nexus users (tofu, ci-push, k8s-pull, admin)
    "DockerToken",
  ]
}

# Adopt the hand-configured realm list (only NexusAuthenticatingRealm was active).
import {
  to = nexus_security_realms.this
  id = "active"
}
