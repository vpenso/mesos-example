#
# Install from the Mesosphere package
#
zookeeper_packages:
  pkg.installed:
    - name: mesosphere-zookeeper

#
# Main configuration file
#
zookeeper_conf:
  file.managed:
    - name: /etc/zookeeper/conf/zoo.cfg
    - source: salt://zookeeper/zoo.cfg

#
# Each node requires an individual ID
#
zookeeper_id:
  file.managed:
    - name: /var/lib/zookeeper/myid
{% if   grains['fqdn'] == 'lxcc01.devops.test' %}
    - content: '1'
{% elif grains['fqdn'] == 'lxcc02.devops.test' %}
    - content: '2'
{% elif grains['fqdn'] == 'lxcc03.devops.test' %}
    - content: '3'
{% endif %}

#
# Open required ports ifr the firewall is active
#
{% if salt['cmd.shell']('firewall-cmd --state') == 'running' %}
zookeeper_firewall:
  firewalld.present:
    - name: public
    - ports:
      - 2181/tcp
      - 2888/tcp
      - 3888/tcp
    - prune_services: False
{% endif %}

#
# Make sure the service is running
#
zookeeper_service:
  service.running:
    - name: zookeeper.service
    - enable: True
    - watch:
      - file: /etc/zookeeper/conf/zoo.cfg
      - file: /var/lib/zookeeper/myid
