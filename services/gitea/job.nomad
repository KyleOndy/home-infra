job "gitea" {
  datacenters = [ "509ely" ]
  type = "service"
  group "vcs" {
    count = 1
    restart {
      attempts = 5
      delay    = "30s"
    }
    network {
      port "http" { to = 3000 }
      port "git_ssh" { static = "8022" }
    }
    service {
      name = "gitea"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.gitea.rule=Host(`git.apps.ondy.org`)",
        "traefik.http.routers.gitea.entrypoints=websecure",
        "traefik.http.routers.gitea.tls=true",
        "traefik.http.routers.gitea.tls.certresolver=myresolver",
      ]
      check {
        type     = "http"
        port     = "http"
        name     = "alive"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "app" {
      driver = "docker"
      config {
        image = "gitea/gitea:1.14.3"
        mount {
          type = "bind"
          target = "/data"
          source = "/mnt/shared/services/gitea"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }
        ports = [
         "http",
         "git_ssh"
       ]
      }
      # todo: do some inital configuration with env vars.
      #env = {
      #  "APP_NAME"   = "Gitea: Git with a cup of tea"
      #  "RUN_MODE"   = "prod"
      #  "SSH_DOMAIN" = "git.example.com"
      #  "SSH_PORT"   = "22"
      #  "ROOT_URL"   = "http://git.example.com/"
      #  "USER_UID"   = "1002"
      #  "USER_GID"   = "1002"
      #  "DB_TYPE"    = "postgres"
      #  "DB_HOST"    = "${NOMAD_ADDR_db_db}"
      #  "DB_NAME"    = "gitea"
      #  "DB_USER"    = "gitea"
      #  "DB_PASSWD"  = "gitea"
      #}
      resources {
        cpu    = 100
        memory = 512
      }
    }
  }
}
