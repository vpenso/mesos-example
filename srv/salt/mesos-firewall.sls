{% if salt['cmd.shell']('firewall-cmd --state') == 'running' %}
mesos_firewall:
  firewalld.present:
    - name: public
    - ports:
      - 5050/tcp
    - prune_services: False
{% endif %}
