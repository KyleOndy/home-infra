datacenter = "509ely"
data_dir = "/opt/consul"
encrypt = "$ENCRYPT_KEY"
# todo: would like to just point to 10.25.89.5, but need to load balance among
# master too fo the case where all nodes are down. By trying to join the fixed
# IPs of the masters, it should work more reliably.
retry_join = ["10.25.89.21","10.25.89.22","10.25.89.23"]
bind_addr = "0.0.0.0"
#bind_addr = "{{ GetInterfaceIP }}"

ui_config {
  enabled = true
}
