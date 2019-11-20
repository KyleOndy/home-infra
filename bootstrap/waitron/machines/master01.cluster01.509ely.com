network:
  - name: master01
    macaddress: 00:15:5d:59:33:08


params:
    ipmi_address: 10.20.25.2
    ipmi_proxy: ipmi01.example.com
    addressing_type: static
