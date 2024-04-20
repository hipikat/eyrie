# # /srv/pillar/docker.sls
# docker:
#   enabled: true
#   version: latest
#   manage_packages: true
#   users:
#     - hipikat



docker:
  wanted:
    - docker
    # - compose
  pkg:
    docker:
      use_upstream: repo