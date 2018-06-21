sysctl_ipv6_disable_all:
  sysctl.present:
    - name: net.ipv6.conf.all.disable_ipv6
    - value: 1
sysctl_ipv6_disable_default:
  sysctl.present:
    - name: net.ipv6.conf.default.disable_ipv6
    - value: 1
