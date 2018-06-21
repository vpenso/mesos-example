firewalld_service_disable:
  service.dead:
    - name: firewalld.service
    - enable: False
  
