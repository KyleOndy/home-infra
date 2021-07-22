# vim: set ft=conf

job "kyleondy-web" {
  datacenters = ["509ely"]
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

  group "kyleondy-web" {
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
      name = "kyleondy-web"
      port = "web"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.kyleondy-web-prod.rule=Host(`www.kyleondy.com`,`kyleondy-web.apps.509ely.com`)",
        "traefik.http.routers.kyleondy-web-prod.entrypoints=websecure",
        #"traefik.http.routers.kyleondy-web-prod.entrypoints=web",
        "traefik.http.routers.kyleondy-web-prod.tls=true",
        "traefik.http.routers.kyleondy-web-prod.tls.certresolver=myresolver",
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

    task "kyleondy-web" {
      driver = "docker"

      config {
        image = "kyleondy/website:ec3c2f7d34d9c2df4b2ff7badbe68f9ea2da8a5c"
        ports = ["web"]
      }

      resources {
        cpu    = 50 # 500 MHz
        memory = 256 # 256MB
      }
    }
  }
}
