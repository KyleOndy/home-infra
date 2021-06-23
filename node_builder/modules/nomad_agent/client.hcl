client {
  enabled = true
   host_volume "shared" {
     path      = "/mnt/shared/nomad"
     read_only = false
   }
}
