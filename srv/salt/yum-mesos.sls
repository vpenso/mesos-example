yum-repos-mesos:
  file.managed:
    - name: /etc/yum.repos.d/mesosphere.repo
    - source: salt://yum.repos.d/mesosphere.repo
