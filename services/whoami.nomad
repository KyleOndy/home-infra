# vim: set ft=conf

job "whoami" {
  datacenters = ["dc1"]
  type        = "service"
  update {
    max_parallel      = 1
    min_healthy_time  = "10s"
    healthy_deadline  = "3m"
    progress_deadline = "10m"
    auto_revert       = false
    canary            = 0
  }

  migrate {
    max_parallel     = 1
    health_check     = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "whoami" {
    count = 3
    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    network {
      # port that docker exposes
      port  "web" { to= 80 }
    }

    service {
      name = "whoami"
      port = "web"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.whoami-prod.rule=Host(`whoami.apps.509ely.com`,`whoami.apps.ondy.org`)",
        "traefik.http.routers.whoami-prod.entrypoints=websecure",
        #"traefik.http.routers.whoami-prod.entrypoints=web",
        "traefik.http.routers.whoami-prod.tls=true",
        "traefik.http.routers.whoami-prod.tls.certresolver=myresolver",
      ]
      check {
        type     = "http"
        port     = "web"
        name     = "alive"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "whoami" {
      driver = "docker"

      config {
        image = "containous/whoami"
        ports = ["web"]
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }
    }
  }
}
