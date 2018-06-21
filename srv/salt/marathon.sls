marathon_package:
  pkg.installed:
    - name: marathon

marathon_conf:
  file.managed:
   - name: /etc/marathon/conf
   - makedirs: True
   - contents: {{ grains['fqdn_ip4'] }}
