mesos_package:
  pkg.installed:
    - name: mesos

mesos_slave_service_disable:
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

mesos_master_service:
  service.running:
    - name: mesos-master.service
    - enable: True
    - watch:
      - file: /etc/mesos-master/quorum
      - file: /etc/mesos-master/ip
      - file: /etc/mesos-master/hostname
