client {
  enabled = true
}

# probably not best practice in a production envroentm, but I control all jobs
# running on these hosts, and it makes my life easier right now.
plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
