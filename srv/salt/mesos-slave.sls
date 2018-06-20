mesos_slave_packages:
  pkg.installed:
    - pkgs:
      - mesos
      - docker

mesos_master_service_disable:
  service.dead:
    - name: mesos-master.service
    - enable: False

mesos_slave_ip:
  file.managed:
    - name: /etc/mesos-slave/ip
    - contents: {{ grains['fqdn_ip4'] }}

mesos_slave_hostname:
  file.managed:
    - name: /etc/mesos-slave/hostname
    - contents: {{ grains['fqdn_ip4'] }}

mesos_slave_containerizers:
  file.managed:
    - name: /etc/mesos-slave/containerizers
    - contents: docker,mesos

mesos_slave_service:
  service.running:
    - name: mesos-slave.service
    - enable: True
    - watch:
      - file: /etc/mesos-slave/ip
      - file: /etc/mesos-slave/hostname
      - file: /etc/mesos-slave/containerizers

