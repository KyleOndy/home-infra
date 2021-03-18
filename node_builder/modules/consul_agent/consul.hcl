datacenter = "dc1"
data_dir = "/opt/consul"
encrypt = "$ENCRYPT_KEY"
# todo: would like to just point to 10.25.89.5, but need to load balance among
# master too fo the case where all nodes are down. By trying to join the fixed
# IPs of the masters, it should work more reliably.
retry_join = ["10.25.89.10","10.25.89.20","10.25.89.30"]
ui = true
#bind_addr = "{{ GetInterfaceIP | exclude \"network\" \"10.25.89.5/32\" | attr \"address\" }}"
# todo: is it safe to assume the VIP will be not the first IP?
bind_addr = "{{ GetInterfaceIP \"enp2s0\" }}"
