# vim: set ft=conf

# todo:
#   - add authentication
#     - nomad user to pull only
#     - normal user for me to push/pull

job "registry2" {
  datacenters = ["dc1"]
  type = "service"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }
  migrate {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }
  group "registry2" {
    network {
      port "web" { to = 5000 }
    }

    service {
      name = "registry2"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.registry2.rule=Host(`registry.apps.ondy.org`)",
        "traefik.http.routers.registry2.entrypoints=websecure",
        "traefik.http.routers.registry2.tls=true",
        "traefik.http.routers.registry2.tls.certresolver=myresolver",
      ]
      port = "web"
      check {
        type     = "http"
        port     = "web"
        name     = "alive"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "registry2" {
      template {
        change_mode = "restart"
        destination = "auth/htpasswd"
        data        = "tmp_user:$2y$05$kWjRYGufTLIte6Ri6QV0aOLffcHujc6j6OtgFzU4TF22xD/689Nku" # pragma: allowlist secret
      }
      env {
       REGISTRY_AUTH = "htpasswd"
       REGISTRY_AUTH_HTPASSWD_REALM = "Registry Realm"
       REGISTRY_AUTH_HTPASSWD_PATH = "/auth/htpasswd"
      }
      driver = "docker"
      config {
        image = "registry:2"
        ports = ["web"]
        volumes = [
          "auth/htpasswd:/auth/htpasswd" # pragma: allowlist secret
        ]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }
    }
  }
}
