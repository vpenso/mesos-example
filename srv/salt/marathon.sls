marathon_package:
  pkg.installed:
    - name: marathon

marathon_conf:
  file.managed:
    - name: /etc/marathon/conf/hostname
    - makedirs: True
    - contents: {{ grains['fqdn_ip4'] }}

marathon_defaults:
  file.managed:
    - name: /etc/default/marathon
    - source: salt://marathon/default
    - backup: minion

marathon_service:
  service.running:
    - name: marathon.service
    - enable: True
    - watch:
      - file: /etc/marathon/conf/hostname
      - file: /etc/default/marathon
