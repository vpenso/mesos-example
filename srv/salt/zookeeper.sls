zookeeper_packages:
  pkg.installed:
    - name: mesosphere-zookeeper

zookeeper_conf:
  file.managed:
    - name: /etc/zookeeper/conf/zoo.cfg
    - file: salt://zookeeper/zoo.cfg

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

zookeeper_firewall:
  firewalld.present:
    - name: public
    - ports:
      - 2181/tcp
      - 2888/tcp
      - 3888/tcp
    - prune_services: False

zookeeper_service:
  service.running:
    - name: zookeeper.service
    - enable: True
    - watch:
      - file: /etc/zookeeper/conf/zoo.cfg
      - file: /var/lib/zookeeper/myid
