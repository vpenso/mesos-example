docker_package:
  pkg.installed:
    - name: docker

docker_service:
  service.running:
    - name: docker.service
    - enable: True
