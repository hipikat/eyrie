# /srv/pillar/docker.sls
docker:
  enabled: true
  version: latest
  manage_packages: true
  users:
    - hipikat
