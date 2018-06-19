mesos_package:
  pkg.installed:
    - name: mesos

mesos_slave_service:
  service.dead:
    - name: mesos-slave.service
    - enable: False

mesos_master_quorum:
  file.managed:
    - name: /etc/mesos-master/quorum
    - contents: '2'

mesos_master_ip:
  file.managed:
    - name: /etc/mesos-master/ip
    - contents: {{ grains['fqdn_ip4'] }}
mesos_master_hostname:
  file.managed:
    - name: /etc/mesos-master/hostname
    - contents: {{ grains['fqdn_ip4'] }}
