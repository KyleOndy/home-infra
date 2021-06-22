job "prometheus" {
  datacenters = ["509ely"]
  type        = "service"

  group "monitoring" {
    count = 1

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "prometheus" {
      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"

        data = <<EOH
---
global:
  scrape_interval:     5s
  evaluation_interval: 5s
EOH
      }

      driver = "docker"

      config {
        image = "prom/prometheus:latest"

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]

        port_map {
          prometheus_ui = 9090
        }
      }

      resources {
        network {
          mbits = 10
          port  "prometheus_ui"{}
        }
      }

      service {
        name = "prometheus"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.prometheus.rule=Host(`prometheus.apps.509ely.com`)",
          "traefik.http.routers.prometheus.entrypoints=websecure",
          "traefik.http.routers.prometheus.tls=true",
          "traefik.http.routers.prometheus.tls.certresolver=myresolver",
          # basic auth for now
          "traefik.http.middlewares.prometheus-auth.basicauth.users=kyle:$apr1$C.zhFNPC$uBk/NdASEIjqnNGGu4Sv//",
        ]
        port = "prometheus_ui"

        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          port     = "prometheus_ui"
          path     = "/graph"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
